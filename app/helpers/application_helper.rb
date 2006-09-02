# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def regular_players
    Player.find_all
  end
end
