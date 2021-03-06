class Scheduler
  include Mongoid::Document

  has_many :simulations, :inverse_of => :scheduler
  scope :active, where(active: true).excludes(run_time_configuration_id: nil, simulator_id: nil)
  field :name
  field :active, :type => Boolean
  field :process_memory, :type => Integer
  field :time_per_sample, :type => Integer
  field :jobs_per_request, :type => Integer
  field :samples_per_simulation, :type => Integer
  field :max_samples, :type => Integer

  after_create :set_run_time_configuration
  belongs_to :simulator
  belongs_to :run_time_configuration


  validates_presence_of :process_memory, :name, :time_per_sample, :jobs_per_request
  validates_numericality_of :process_memory, :time_per_sample, :jobs_per_request, :only_integer => true
  validates_numericality_of :samples_per_simulation, :max_samples, :only_integer=>true, :greater_than=>0

  def name
    "#{self.class}-#{self.time_per_sample}-#{self.process_memory}-#{self.qos}"
  end

  def set_run_time_configuration
    if run_time_configuration == nil
      self.update_attribute(:run_time_configuration_id, simulator.run_time_configurations.first.id)
    end
  end

  def find_account
    account = nil
    Account.all.each do |a|
      if a.schedulable?
        account = a
        break
      end
    end

    account
  end
end