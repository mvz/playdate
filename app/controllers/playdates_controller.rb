class PlaydatesController < ApplicationController
  before_filter :authorize_admin

  PERIOD_THIS_MONTH = 1
  PERIOD_NEXT_MONTH = 2
  # TODO: Use something more robust?
  DAY_FRIDAY = 5 # Date::DAYS["friday"]
  DAY_SATURDAY = 6 # Date::DAYS["saturday"]

  def destroy
    if request.delete?
      pd = Playdate.find(params[:id])
      # FIXME: Can't this be done automatically?
      pd.availabilities.each { |av| av.destroy }
      pd.destroy
      flash[:notice] = 'De speeldag is verwijderd.'
      redirect_to :action => 'index'
    end
  end

  def edit
    @playdate = Playdate.find(params[:id])
  end

  def update
    @playdate = Playdate.find(params[:id])
    if request.put?
      if @playdate.update_attributes(params[:playdate])
        flash[:notice] = 'De speeldag is gewijzigd.'
        redirect_to :action => 'show', :id => @playdate
      end
    end
  end

  def index
    @playdates = Playdate.paginate(:page => params[:page], :order => 'day')
  end

  def new
    @period = PERIOD_THIS_MONTH
    @daytype = DAY_SATURDAY
    @playdate = Playdate.new
  end

  def create
    @period = (params[:period] || PERIOD_THIS_MONTH).to_i
    @daytype = (params[:daytype] || DAY_SATURDAY).to_i
    @playdate = Playdate.new(params[:playdate])
    if request.post?
      if params[:playdate]
        save_new_playdate(@playdate)
      else
        save_new_range(@period, @daytype)
      end
    end
  end

  def show
    @playdate = Playdate.find(params[:id])
  end

  def prune
    if request.post?
      Playdate.irrelevant.each do |pd|
        pd.availabilities.each { |av| av.destroy }
        pd.destroy
      end
      flash[:notice] = 'Oude speeldagen zijn opgeruimd.'
      redirect_to :action => 'index'
    end
  end

  private
  def save_new_playdate(pd)
    if pd.save
      flash[:notice] = 'De nieuwe speeldag is toegevoegd.'
      redirect_to :action => 'index'
    end
  end

  def save_new_range(period, daytype)
    unless [DAY_SATURDAY, DAY_FRIDAY].include?(daytype)
      flash[:notice] = "Invalid day!"
      redirect_to :action => 'edit'
      return
    end
    unless [PERIOD_THIS_MONTH, PERIOD_NEXT_MONTH].include?(period)
      flash[:notice] = "Invalid period!"
      redirect_to :action => 'edit'
      return
    end

    count = Playdate.make_new_range(period, daytype)

    if count > 0
      flash[:notice] = "Saved #{count}."
      redirect_to :action => 'index'
    else
      flash[:notice] = "Er zijn geen nieuwe datums toegevoegd."
    end
  end
end
