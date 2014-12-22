module ApplicationHelper
  MODEL_TRANSLATIONS = {
    'password' => 'Wachtwoord'
  }
  def regular_players
    Player.all.order(:abbreviation)
  end

  def availability_options
    Availability::VALUES.map do |v|
      [Availability::LONG_DISPLAY[v], v]
    end
  end

  def errors_for(obj)
    return '' if obj.nil? || obj.errors.empty?
    result = content_tag('h3', 'Fout')
    result << content_tag('p', 'Controleer de invoer en probeer het opnieuw')
    list = ''
    obj.errors.each do |at, ms|
      list << content_tag('li', "#{MODEL_TRANSLATIONS[at]} #{ms}.")
    end
    result << content_tag('ul', list)
    result
  end

  def status_display(status)
    Availability::LONG_DISPLAY[status]
  end
end
