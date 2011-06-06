class SchedulersController < StrategyController
  def create
    @scheduler = klass.new(params[single_name])
    if @scheduler.save
      redirect_to "/#{plural_name}/step2/#{@scheduler.id}"
    else
      render :action => "new"
    end
  end

  def step2
    @scheduler = Scheduler.find(params[:id])
    render "schedulers/step2"
  end

  def step2_commit
    @scheduler = Scheduler.find(params[:id])
    @scheduler.update_attribute(:simulator_id, params[single_name][:simulator_id])
    redirect_to "/#{plural_name}/step3/#{@scheduler.id}"
  end

  def step3
    @scheduler = Scheduler.find(params[:id])
    render "schedulers/step3"
  end

  def step2_commit
    @scheduler = Scheduler.find(params[:id])
    @scheduler.update_attribute(:simulator_id, params[single_name][:simulator_id])
    redirect_to "/#{plural_name}/step3/#{@scheduler.id}"
  end

  def step3_commit
    @scheduler = Scheduler.find(params[:id])
    @simulator = Simulator.find(@scheduler.simulator_id)
    @rtc = RunTimeConfiguration.new(:parameters => params[:run_time_configuration][:parameters])
    @simulator.run_time_configurations << @rtc
    @rtc.save!
    @scheduler.update_attribute(:run_time_configuration_id, @rtc.id)
    redirect_to url_for(:action => "show", :id => entry.id), :notice => "#{klass_name} was successfully created."
  end

  def show
    @profiles = entry.profiles.order("name DESC").page(params[:page]).per(20)
    render "documents/show"
  end
end
