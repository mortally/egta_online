# This model class represents available strategies for a Game

class Strategy
  include Mongoid::Document

  field :name

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :game
  embedded_in :simulator, :inverse_of => :strategies
  embedded_in :game

  before_destroy :kill_profiles

  def kill_profiles
    game.profiles.contains_strategy(name).destroy_all
  end
end
