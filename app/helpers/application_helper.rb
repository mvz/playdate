# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def regular_players
    Player.find(:all, :order => "abbreviation")
  end
  def availability_options
    Availability::VALUES.map do |v|
      [Availability::LONG_DISPLAY[v], v]
    end
  end
end
