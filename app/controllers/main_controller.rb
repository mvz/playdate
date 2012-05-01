class MainController < ApplicationController
  before_filter :authorize, :except => :feed

  MIN_PLAYERS = 4

  def index
    set_overview_fields
  end

  def edit
    @playdates = relevant_playdates
    if request.post?
      params[:availability].each do |p_id, av_param|
        d = Playdate.find(p_id) or next
        av = @current_user.availability_for_playdate(d) ||
          @current_user.availabilities.build({:playdate => d})
        av.status = av_param[:status]
        av.save!
      end
      flash[:notice] = 'Wijzigingen opgeslagen.'
      redirect_to :action => 'index'
    end
  end

  def more
    if request.post?
      last_date = Playdate.last.day
      today = Date.today
      if last_date < today
        last_date = today
      end
      eom = today.end_of_month

      period = 1
      if last_date + 7 > today.end_of_month
        period = 2
      end

      count = Playdate.make_new_range(period, PlaydatesController::DAY_SATURDAY)
      count += Playdate.make_new_range(period, PlaydatesController::DAY_FRIDAY)
      if count > 0 then
        flash[:notice] = 'Data toegevoegd'
      else
        flash[:notice] = 'Geen data toegevoegd'
      end
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

    @content = render_to_string :partial => "main/feed_table", :formats => "html"
    render :layout => false
  end

  private

  def relevant_playdates
    Playdate.relevant
  end

  def set_overview_fields
    @players = Player.all
    @playdates = relevant_playdates
    @stats = statistics(@playdates, @players)
    @max = @stats.map {|d,s| s[:yes] }.max
  end

  def statistics(dates, players)
    stats = dates.inject({}) do |h,pd|
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
      house = stat[Availability::STATUS_HUIS]
      h[pd] = { :yes => yes, :no => no, :maybe => maybe, :house => house }
      h
    end

    max = stats.map {|d,s| s[:yes] }.max
    max_has_house = (not stats.find {
      |d,s| s[:yes] == max && s[:house] > 0}.nil?)
    numplayers = players.length
    min = [numplayers, MainController::MIN_PLAYERS].min

    stats.each_value do |s|
      s[:code] = status_code(s, min, max, max_has_house, numplayers)
    end
  end

  def status_code(status, min, max, max_has_house, numplayers)
    if max >= min && status[:yes] == max
      if max_has_house
        return 3 if status[:house] > 0
        return 2
      else
        return 3
      end
    end
    return 2 if status[:yes] >= min
    return 0 if status[:no] > (numplayers - min)
    return 1
  end
end
