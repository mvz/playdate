class Playdate < ActiveRecord::Base
  has_many :availabilities
  has_many :players, :through => :availabilities
  validates_presence_of :day
  validates_uniqueness_of :day

  def to_s
    self.day.strftime
  end
end
