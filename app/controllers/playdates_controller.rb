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
      Playdate.find(params[:id]).destroy
      flash[:notice] = 'The playdate was successfully destroyed.'
      redirect_to :action => 'list'
    else
      flash[:notice] = 'Click Destroy to destroy the playdate.'
      redirect_to :action => 'edit', :id => params[:id]
    end
  end

  def edit
    @playdate = Playdate.find(params[:id])
    if request.post?
      if @playdate.update_attributes(params[:playdate])
        flash[:notice] = 'The playdate was successfully edited.'
        redirect_to :action => 'show', :id => @playdate
      end
    end
  end

  def list
    @playdate_pages, @playdates = paginate(:playdates)
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

  private
  def save_new_playdate(pd)
    if pd.save
      flash[:notice] = 'A new playdate was successfully added.'
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
