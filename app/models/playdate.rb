class Playdate < ActiveRecord::Base
  has_many :availabilities
  has_many :players, :through => :availabilities
  validates_presence_of :day

  def status
    #players = Player.find_all.length
    stat = Hash.new(0)
    self.availabilities.each { |av| stat[av.status] += 1 }
    yes = stat[Availability::STATUS_JA] + stat[Availability::STATUS_HUIS]
    no = stat[Availability::STATUS_NEE]
    maybe = stat[Availability::STATUS_MISSCHIEN]
    #return "superbest" if yes == players 
    #return "badass" if no == players 
    "#{players}:#{yes}/#{no}/#{maybe}"
    { :yes => yes, :no => no, :maybe => maybe }
  end
end
