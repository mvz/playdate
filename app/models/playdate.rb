class Playdate < ActiveRecord::Base
  has_many :availabilities
  has_many :players, :through => :availabilities
end
