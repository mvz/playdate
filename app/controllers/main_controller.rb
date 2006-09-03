class MainController < ApplicationController
  before_filter :authorize

  MIN_PLAYERS = 4

  def index
    @players = Player.find(:all, :order => "abbreviation")
    @playdates = relevant_playdates
    @stats = @playdates.map {|p| p.status }
    @max = @stats.map {|s| s[:yes] }.max
  end

  def edit
    @playdates = relevant_playdates
    if request.post?
      avs = @current_user.availabilities_by_day
      params[:availability].each do |p_id, av_param|
        p = Playdate.find(p_id) or next
        av = avs[p.day] ||
          @current_user.availabilities.build({:playdate => p})
        av.status = av_param[:status]
        av.save!
      end
      flash[:notice] = 'Wijzigingen succesvol.'
      redirect_to :action => 'index'
    end
  end
  private
  def relevant_playdates
    Playdate.find(:all, :order => "day",
                  :conditions => ["day >= ?", Date.today])
  end
end
