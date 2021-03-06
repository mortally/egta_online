class ServerProxy

  attr_accessor :sessions, :staging_session

  def start
    @sessions = Net::SSH::Multi.start
    @staging_session = Net::SSH.start(Yetting.host, Account.first.username, :password => Account.first.password)
    @sessions.group :scheduling do
      Account.all.each {|account| @sessions.use(Yetting.host, :user => account.username, :password => account.password)}
    end
  end

  def stop
    @sessions.close
    @staging_session.close
  end

  def setup_simulator(simulator)
    @staging_session.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
    @staging_session.scp.upload!(simulator.simulator_source.path, Yetting.deploy_path)
    @staging_session.exec!("cd #{Yetting.deploy_path}; unzip -uqq #{simulator.name}.zip -d #{simulator.fullname}; mkdir #{simulator.fullname}/simulations")
    @staging_session.exec!("cd #{Yetting.deploy_path}; chmod -R ug+rwx #{simulator.fullname}")
  end

  def queue_pending_simulations
    queue_account = Account.first
    while Simulation.pending.count != 0 && queue_account != nil
      first_sim = Simulation.pending.first
      queue_account = Account.all.select{|account| account.max_concurrent_simulations-Simulation.active.where(:account_id => account.id).count >= first_sim.scheduler.jobs_per_request}.sample
      if queue_account != nil
        simulations = Array.new
        Simulation.pending.where(:profile_id.in => first_sim.game.profiles.collect{|profile| profile.id}).limit(first_sim.scheduler.jobs_per_request).each do |simulation|
          simulation.update_attributes(:account_id => queue_account.id)
          simulations << simulation
        end
        simulations.each do |simulation|
          create_yaml(simulation)
          setup_hierarchy(simulation)
        end
        nyx_processing(simulations)
      end
    end
  end

  def check_simulations
    if Simulation.active.length > 0
      simulations = Simulation.active
      if simulations.length > 0
        output = @staging_session.exec!("qstat -a | grep mas-")
        job_id = []
        state_info = []
        if output != nil && output != ""
          outputs = output.split("\n")
          outputs.each do |job|
            job_id << job.split(".").first
            state_info << job.split(/\s+/)
          end
        end
        simulations.each {|simulation| check_status(simulation, job_id, state_info) }
      end
    end
  end

  def create_yaml(simulation)
    File.open( "#{ROOT_PATH}/tmp/temp.yaml", 'w' ) do |out|
      YAML.dump(Profile.find(simulation.profile_id).yaml_rep, out)
      YAML.dump(numeralize(simulation.game), out)
    end
  end

  def setup_hierarchy(simulation)
    @staging_session.exec!("mkdir -p #{Yetting.deploy_path}/#{simulation.game.simulator.fullname}/simulations/#{simulation.number}/features")
    @staging_session.scp.upload!("#{ROOT_PATH}/tmp/temp.yaml", "#{Yetting.deploy_path}/#{simulation.game.simulator.fullname}/simulations/#{simulation.number}/simulation_spec.yaml")
    @staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulation.game.simulator.fullname}/simulations/#{simulation.number}")
  end

  def nyx_processing(simulations)
    simulator = simulations[0].game.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    account = simulations[0].account
    submission = PBS::MASSubmission.new(simulations[0].scheduler, simulations[0].size, simulations[0].number, "#{root_path}/script/wrapper")
    submission.qos = "wellman_flux" if simulations[0].flux?
    create_wrapper(simulations)
    @staging_session.scp.upload!("#{ROOT_PATH}/tmp/wrapper", "#{root_path}/script/")
    @staging_session.exec!("chmod -R ug+rwx #{root_path}; chgrp -R wellman #{root_path}")
    @job = get_job(account, simulator, submission)
    if submission
      if submission && @job != "" && @job != nil
        simulations.each do |simulation|
          simulation.send('queue!')
          simulation.job_id = @job
          simulation.save
        end
      else
        simulations.each{|simulation| simulation.send('fail!')}
      end
    end
  end

  def create_wrapper(simulations)
    simulator = simulations[0].game.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    FileUtils.cp(ROOT_PATH + "/tmp/wrapper-template", ROOT_PATH + "/tmp/wrapper")
    File.open(ROOT_PATH + "/tmp/wrapper", "a") do |file|
      if simulations[0].flux?
        file.syswrite("\n\#PBS -A wellman_flux\n\#PBS -q flux")
      else
        file.syswrite("\n\#PBS -q route")
      end
      file.syswrite("\n\#PBS -N mas-#{simulator.name.downcase.gsub(' ', '_')}\n")
      str = "\#PBS -t "
      simulations.each_index do |i|
        if i == 0
          str += "#{simulations[0].number}"
        else
          str += ",#{simulations[i].number}"
        end
      end
      str += "\n"
      file.syswrite(str)
      file.syswrite("\#PBS -o #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
      file.syswrite("\#PBS -e #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
      file.syswrite("mkdir /tmp/${PBS_JOBID}; cd /tmp/${PBS_JOBID}; cp -r #{root_path}/* .; cp -r #{root_path}/../simulations/${PBS_ARRAYID} .\n")
      file.syswrite("/tmp/${PBS_JOBID}/script/batch /tmp/${PBS_JOBID}/${PBS_ARRAYID} #{simulations[0].size}\n")
      file.syswrite("cp -r ${PBS_ARRAYID} #{root_path}/../simulations; /bin/rm -rf /tmp/${PBS_JOBID}")
    end
  end

  def check_existance(root_path, simulation)
    output = @staging_session.exec!("if test -e #{root_path}/../simulations/#{simulation.number}/out-#{simulation.number}; then printf \"exists\"; fi")
    if output == "exists"
      server = @sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
      server.session(true).exec!("chgrp -R wellman #{root_path}/../simulations/#{simulation.number}; chmod -R ug+rwx #{root_path}/../simulations/#{simulation.number}")
    end
    output == "exists"
  end

  def check_for_errors(simulation)
    if File.open("#{ROOT_PATH}/db/#{simulation.number}/out-#{simulation.number}").read == ""
      DataParser.parse(simulation.number)
      simulation.finish!
    else
      simulation.error_message = File.open("#{ROOT_PATH}/db/#{simulation.number}/out-#{simulation.number}").readline
      simulation.fail!
    end
  end

  def check_status(simulation, job_id, state_info)
    simulator = simulation.game.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    if job_id.include?(simulation.job_id)
      state = state_info[job_id.index(simulation.job_id)][9]
      puts state_info
      if state == "C"
        if check_existance(root_path, simulation)
          @staging_session.scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{ROOT_PATH}/db/", :recursive => true)
          check_for_errors(simulation)
        end
      elsif state == "R" && simulation.state != "running"
        simulation.start!
      end
    elsif state != "Q"
      if check_existance(root_path, simulation)
        @staging_session.scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{ROOT_PATH}/db/", :recursive => true)
        check_for_errors(simulation)
      else
        simulation.fail!
      end
    end
  end

  def get_job(account, simulator, submission)
    job_return = ""
    if submission != nil
      server = @sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == account.username}
      channel = server.session(true).exec("cd #{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}/script; #{submission.command}") do |ch, stream, data|
        job_return = data
        puts "[#{ch[:host]} : #{stream}] #{data}"
        job_return.strip! if job_return != nil
        job_return = job_return.split(".").first
      end
      channel.wait

      if channel[:exit_status] != 0 and channel[:exit_status] != "" and channel[:exit_status] != nil
        puts channel[:exit_status]
      end
    end
    job_return
  end

  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def numeralize(game)
    p = Hash.new
    game.parameters.each_pair do |x, y|
      if is_a_number?(y)
        p[x] = y.to_f
      else
        p[x] = y
      end
    end
    p
  end
end
