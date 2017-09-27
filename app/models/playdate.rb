class Playdate < ApplicationRecord
  has_many :availabilities, dependent: :destroy
  has_many :players, through: :availabilities

  validates :day, presence: true
  validates :day, uniqueness: true

  default_scope { order('day') }
  scope :relevant, -> { where('day >= ?', Time.zone.today) }
  scope :irrelevant, -> { where('day < ?', Time.zone.today) }

  def to_s
    day.strftime
  end

  def self.make_new_range(months, daytype)
    today = Time.zone.today
    start = (daytype - today.wday) % 7

    finish = 31 * months
    enddate = today.months_since(months).beginning_of_month

    count = 0

    (start..finish).step(7) do |d|
      nw = today + d
      break if nw >= enddate
      unless Playdate.find_by(day: nw)
        Playdate.new(day: nw).save
        count += 1
      end
    end
    count
  end
end
