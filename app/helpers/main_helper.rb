# frozen_string_literal: true

module MainHelper
  STATUS_CLASSES = %w[bad neutral option best].freeze
  STATUS_TEXTS = ["Nee", "", "Ja", "Beste"].freeze # "Misschien" for "" ?
  CANDIDATE_WEEKDAYS = [5, 6].freeze

  def status_to_class(status)
    STATUS_CLASSES[status[:code]]
  end

  def status_to_text(status)
    STATUS_TEXTS[status[:code]]
  end

  def class_if_current_user(player)
    player == current_user ? "current" : ""
  end

  def nice_date_display(date)
    "#{date.mday}/#{date.mon}"
  end

  def availability_status_character(availability, player)
    return Availability::SHORT_DISPLAY[availability.status] unless availability.nil?

    s = player.default_status || Availability::STATUS_MISSCHIEN
    return "" if s == Availability::STATUS_MISSCHIEN

    "(#{Availability::SHORT_DISPLAY[s]})"
  end

  def can_dates_be_added?
    startdate = Time.zone.today + 1
    enddate = Time.zone.today.next_month.end_of_month
    candidates = startdate.upto(enddate)
      .select { |day| CANDIDATE_WEEKDAYS.include?(day.wday) }
    Playdate.where(day: candidates).count < candidates.count
  end
end
