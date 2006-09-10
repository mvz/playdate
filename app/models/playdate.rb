class Playdate < ActiveRecord::Base
  has_many :availabilities
  has_many :players, :through => :availabilities
  validates_presence_of :day
  validates_uniqueness_of :day

  def status
    stat = Hash.new(0)
    # TODO: We really should be using symbols here. This just sucks.
    Player.find(:all).each do |p|
      av = p.availability_for_playdate(self)
      s = av.status
      s = (s == Availability::STATUS_USE_DEFAULT) ?  p.default_status || Availability::STATUS_MISSCHIEN : s
      stat[s] += 1
    end
    yes = stat[Availability::STATUS_JA] + stat[Availability::STATUS_HUIS]
    no = stat[Availability::STATUS_NEE]
    maybe = stat[Availability::STATUS_MISSCHIEN]
    { :yes => yes, :no => no, :maybe => maybe }
  end

  def to_s
    self.day.strftime
  end
end
