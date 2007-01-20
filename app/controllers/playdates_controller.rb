class PlaydatesController < ApplicationController
  before_filter :authorize
  verify :only => [ 'show', 'edit', 'destroy' ],
         :params => :id,
         :add_flash => { :notice => 'Missing playdate ID.' },
         :redirect_to => { :action => 'list' }

  PERIOD_THIS_MONTH = 1
  PERIOD_NEXT_MONTH = 2
  # TODO: Use constants from Date directly
  DAY_FRIDAY = Date::DAYS["friday"]
  DAY_SATURDAY = Date::DAYS["saturday"]

  def destroy
    if request.post?
      pd = Playdate.find(params[:id])
      # FIXME: Can't this be done automatically?
      pd.availabilities.each { |av| av.destroy }
      pd.destroy
      flash[:notice] = 'De speeldag is verwijderd.'
      redirect_to :action => 'list'
    else
      flash[:notice] = 'Kies Verwijderen om de speeldag te verwijderen.'
      redirect_to :action => 'edit', :id => params[:id]
    end
  end

  def edit
    @playdate = Playdate.find(params[:id])
    if request.post?
      if @playdate.update_attributes(params[:playdate])
        flash[:notice] = 'De speeldag is gewijzigd.'
        redirect_to :action => 'show', :id => @playdate
      end
    end
  end

  def list
    @playdate_pages, @playdates = paginate(:playdates, :order => 'day')
  end

  def new
    @period = (params[:period] || PERIOD_THIS_MONTH).to_i
    @daytype = (params[:daytype] || DAY_SATURDAY).to_i
    @playdate = Playdate.new(params[:playdate])
    if request.post?
      if params[:playdate]
        save_new_playdate(@playdate)
      else
        save_new_range(@period, @daytype)
      end
    #else
    #  @playdate = Playdate.new
    end
  end

  def show
    @playdate = Playdate.find(params[:id])
  end

  def prune
    if request.post?
      Playdate.find(:all, :conditions => "day < '#{Date.today()}'").each do |pd|
        pd.availabilities.each { |av| av.destroy }
        pd.destroy
      end
      flash[:notice] = 'Oude speeldagen zijn opgeruimd.'
      redirect_to :action => 'list'
    end
  end

  private
  def save_new_playdate(pd)
    if pd.save
      flash[:notice] = 'De nieuwe speeldag is toegevoegd.'
      redirect_to :action => 'list'
    end
  end

  def save_new_range(period, daytype)
    unless [DAY_SATURDAY, DAY_FRIDAY].include?(daytype)
      flash[:notice] = "Invalid day!"
      return
    end
    unless [PERIOD_THIS_MONTH, PERIOD_NEXT_MONTH].include?(period)
      flash[:notice] = "Invalid period!"
      return
    end

    today = Date.today()
    start = (daytype - today.wday) % 7

    case period  
    when PERIOD_THIS_MONTH 
      finish = 31; endmonth = today.month
    when PERIOD_NEXT_MONTH
      finish = 62; endmonth = today.month + 1
    end

    count = 0

    (start..finish).step(7) do |d|
      nw = today + d
      break if nw.month > endmonth
      unless Playdate.find_by_day(nw)
        Playdate.new(:day => nw).save
        count += 1
      end
    end
    if count > 0
      flash[:notice] = "Saved #{count}."
      redirect_to :action => 'list'
    else
      flash[:notice] = "Er zijn geen nieuwe datums toegevoegd."
    end
  end


end
