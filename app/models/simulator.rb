require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document
  include StrategyManipulation

  mount_uploader :simulator_source, SimulatorUploader
  field :name
  field :description
  field :version
  field :setup, :type => Boolean, :default => false
  field :strategy_array, :type => Array, :default => []
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :profiles, :dependent => :destroy
  has_many :schedulers, :dependent => :destroy
  has_many :run_time_configurations
  validate :parameters
  validate :setup_simulator
  after_create { run_time_configurations << @rtc; @rtc.save! unless @rtc == nil}

  def parameters
    begin
      if setup == false
        system("rm -rf #{location}/#{name}")
        puts "removed"
        system("unzip -uqq #{simulator_source.path} -d #{location}")
        puts "unzipped"
        File.open(location+"/"+name+"/simulation_spec.yaml") do |io|
          @rtc = RunTimeConfiguration.new(:parameters => YAML.load(io)["web parameters"])
          if @rtc.save != true || @rtc.parameters == nil
            raise "invalid rtc"
          end
        end
      else
        return
      end
    rescue
      errors.add(:run_time_configurations, "has invalid run time configuration file")
    end
  end

  def location
    ROOT_PATH+"/simulator_uploads/"+fullname
  end

  def fullname
    name+"-"+version
  end

  def setup_simulator
    begin
      if setup == false
        sp = ServerProxy.new
        sp.start
        sp.setup_simulator(self)
        update_attribute(:setup, true)
      else
        return
      end
    rescue
      errors.add(:simulator_source, "couldn't be uploaded to destination")
    end
  end
end
