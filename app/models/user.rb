class User
  include Mongoid::Document
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :email, :password
end
