class MainController < ApplicationController
  before_filter :authorize, :except => :feed

  MIN_PLAYERS = 4

  def index
    set_overview_fields
  end

  def edit
    @playdates = relevant_playdates
    if request.post?
      avs = @current_user.availabilities_by_day
      params[:availability].each do |p_id, av_param|
        d = Playdate.find(p_id) or next
        av = avs[d.day] ||
          @current_user.availabilities.build({:playdate => d})
        av.status = av_param[:status]
        av.save!
      end
      flash[:notice] = 'Wijzigingen opgeslagen.'
      redirect_to :action => 'index'
    end
  end
  
  def feed
    set_overview_fields

    @feed_title = "Playdate! The Application"
    headers["Content-Type"] = "application/atom+xml; charset=utf-8"
    @link = url_for :action => "index"

    @updated_at = @playdates.map { |d|
      d.availabilities.map { |a|
        a.updated_at} }.flatten.reject {|t| t.nil?}.max

    @content = render_to_string :partial => "main/feed_table"
    render :layout => false
  end

  private

  def relevant_playdates
    Playdate.find(:all, :order => "day",
                  :conditions => ["day >= ?", Date.today])
  end

  def set_overview_fields
    @players = Player.find(:all, :order => "abbreviation")
    @playdates = relevant_playdates
    @stats = statistics(@playdates, @players)
    @max = @stats.map {|d,s| s[:yes] }.max
  end

  def statistics(dates, players)
    return dates.inject({}) do |h,pd|
      stat = Hash.new(0)
      players.each do |p|
        av = p.availability_for_playdate(pd)
        s = av.nil? ?
          p.default_status || Availability::STATUS_MISSCHIEN :
          av.status
        stat[s] += 1
      end
      yes = stat[Availability::STATUS_JA] + stat[Availability::STATUS_HUIS]
      no = stat[Availability::STATUS_NEE]
      maybe = stat[Availability::STATUS_MISSCHIEN]
      h[pd] = { :yes => yes, :no => no, :maybe => maybe }
      h
    end
  end
end
