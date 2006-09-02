class MainController < ApplicationController
  before_filter :authorize
  def index
    @playdates = Playdate.find(:all, :order => "day")
  end
end
