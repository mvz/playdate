module MainHelper
  STATUS_CLASSES = ["bad", "neutral", "option", "best"]
  STATUS_TEXTS = ["Nee", "", "Ja", "Beste"] # "Misschien" for "" ?
  def status_to_class(status, max, numplayers)
    return STATUS_CLASSES[status_code(status, max, numplayers)]
  end
  def status_to_text(status, max, numplayers)
    return STATUS_TEXTS[status_code(status, max, numplayers)]
  end
  def status_code(status, max, numplayers)
    min = [numplayers, MainController::MIN_PLAYERS].min
    return 3 if max >= min && status[:yes] == max
    return 2 if status[:yes] >= min
    return 0 if status[:no] > (numplayers - min)
    return 1
  end
  def class_if_current_user(player)
    player == @current_user ? "current" : ""
  end
  def nice_date_display(date)
    "#{date.mday}/#{date.mon}"
  end
  def availability_status_character(av, pl)
    if av.nil?
      s = pl.default_status || Availability::STATUS_MISSCHIEN
      return "" if s == Availability::STATUS_MISSCHIEN
      return "(" + Availability::SHORT_DISPLAY[s] + ")"
    else
      return Availability::SHORT_DISPLAY[av.status]
    end
  end
  def can_dates_be_added?
    startdate = Date.today + 1
    enddate = Date.today.next_month.end_of_month
    (startdate).upto(enddate) do |day|
      if [5, 6].include?(day.wday) and (not Playdate.find_by_day(day)) then
        return true
      end
    end
    return false
  end
end
