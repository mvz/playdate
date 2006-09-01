class MainController < ApplicationController
  def index
    @playdates = Playdate.find_all()
  end
end
