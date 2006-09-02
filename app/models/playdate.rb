class Playdate < ActiveRecord::Base
  has_many :availabilities
  has_many :players, :through => :availabilities
  validates_presence_of :day
end
