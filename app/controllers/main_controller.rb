class MainController < ApplicationController
  before_filter :authorize

  MIN_PLAYERS = 4

  #verify :only => [ 'edit' ],
  #       :params => :id,
  #       :add_flash => { :notice => 'Missing player ID.' },
  #       :redirect_to => { :action => 'index' }

  def index
    @players = Player.find(:all, :order => "abbreviation")
    @playdates = Playdate.find(:all, :order => "day")
    @stats = @playdates.map {|p| p.status }
    @max = @stats.map {|s| s[:yes] }.max
  end

  def edit
    @playdates = Playdate.find(:all, :order => "day")
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
end
