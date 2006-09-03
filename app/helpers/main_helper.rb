module MainHelper
  def status_to_class(status, max, numplayers)
    return "best" if max >= MainController::MIN_PLAYERS && status[:yes] == max
    return "option" if status[:yes] >= MainController::MIN_PLAYERS
    return "bad" if status[:no] > (numplayers - MainController::MIN_PLAYERS)
    return "neutral"
  end
  def status_to_text(status, max, numplayers)
    return "Beste" if max >= MainController::MIN_PLAYERS && status[:yes] == max
    return "Ja" if status[:yes] >= MainController::MIN_PLAYERS
    return "Nee" if status[:no] > (numplayers - MainController::MIN_PLAYERS)
    return "Kweenie"
  end
end
