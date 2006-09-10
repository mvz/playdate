class MainController < ApplicationController
  before_filter :authorize

  MIN_PLAYERS = 4

  def index
    @players = Player.find(:all, :order => "abbreviation")
    @playdates = relevant_playdates
    @stats = @playdates.inject({}) do |h,pd|
      stat = Hash.new(0)
      @players.each do |p|
        av = p.availability_for_playdate(pd)
        s = av.nil? ?  p.default_status || Availability::STATUS_MISSCHIEN : av.status
        stat[s] += 1
      end
      yes = stat[Availability::STATUS_JA] + stat[Availability::STATUS_HUIS]
      no = stat[Availability::STATUS_NEE]
      maybe = stat[Availability::STATUS_MISSCHIEN]
      h[pd] = { :yes => yes, :no => no, :maybe => maybe }
      #h[pd] = pd.status
      h
    end
    @max = @stats.map {|d,s| s[:yes] }.max
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
