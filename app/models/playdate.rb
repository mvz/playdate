class Playdate < ActiveRecord::Base
  has_many :availabilities, dependent: :destroy
  has_many :players, through: :availabilities

  validates_presence_of :day
  validates_uniqueness_of :day

  default_scope -> { order('day') }
  scope :relevant, -> { where('day >= ?', Date.today) }
  scope :irrelevant, -> { where('day < ?', Date.today) }

  def to_s
    day.strftime
  end

  def self.make_new_range(months, daytype)
    today = Date.today
    start = (daytype - today.wday) % 7

    finish = 31 * months
    enddate = today.months_since(months).beginning_of_month

    count = 0

    (start..finish).step(7) do |d|
      nw = today + d
      break if nw >= enddate
      unless Playdate.find_by_day(nw)
        Playdate.new(day: nw).save
        count += 1
      end
    end
    count
  end
end
