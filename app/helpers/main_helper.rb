module MainHelper
  STATUS_CLASSES = %w(bad neutral option best).freeze
  STATUS_TEXTS = ['Nee', '', 'Ja', 'Beste'].freeze # "Misschien" for "" ?

  def status_to_class(status)
    STATUS_CLASSES[status[:code]]
  end

  def status_to_text(status)
    STATUS_TEXTS[status[:code]]
  end

  def class_if_current_user(player)
    player == @current_user ? 'current' : ''
  end

  def nice_date_display(date)
    "#{date.mday}/#{date.mon}"
  end

  def availability_status_character(av, pl)
    return Availability::SHORT_DISPLAY[av.status] unless av.nil?
    s = pl.default_status || Availability::STATUS_MISSCHIEN
    return '' if s == Availability::STATUS_MISSCHIEN
    '(' + Availability::SHORT_DISPLAY[s] + ')'
  end

  def can_dates_be_added?
    startdate = Time.zone.today + 1
    enddate = Time.zone.today.next_month.end_of_month
    startdate.upto(enddate) do |day|
      return true if [5, 6].include?(day.wday) && !Playdate.find_by_day(day)
    end
    false
  end
end
