class MainController < ApplicationController
  def index
    @playdates = Playdate.find(:all, :order => "day")
  end
end
