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
end
