# frozen_string_literal: true

module ApplicationHelper
  MODEL_TRANSLATIONS = {
    "password" => "Wachtwoord"
  }.freeze
  def regular_players
    Player.all.order(:abbreviation)
  end

  def availability_options
    Availability::VALUES.map do |v|
      [Availability::LONG_DISPLAY[v], v]
    end
  end

  def errors_for(obj)
    return "" if obj.nil? || obj.errors.empty?

    result = tag.h3("Fout")
    result << tag.p("Controleer de invoer en probeer het opnieuw")
    list = +""
    obj.errors.each do |error|
      list << tag.li("#{MODEL_TRANSLATIONS[error.attribute]} #{error.message}.")
    end
    result << tag.ul(list)
    result
  end

  def status_display(status)
    Availability::LONG_DISPLAY[status]
  end
end
