# frozen_string_literal: true

class PlaydatesController < ApplicationController
  respond_to :html
  before_action :authorize_admin

  PERIOD_THIS_MONTH = 1
  PERIOD_NEXT_MONTH = 2
  # TODO: Use something more robust?
  DAY_FRIDAY = 5 # Date::DAYS["friday"]
  DAY_SATURDAY = 6 # Date::DAYS["saturday"]
  def index
    @playdates = Playdate.order(:day).paginate(page: params[:page])
  end

  def show
    @playdate = Playdate.find(params[:id])
  end

  def new
    @period = PERIOD_THIS_MONTH
    @daytype = DAY_SATURDAY
    @playdate = Playdate.new
  end

  def create
    if params[:playdate]
      @playdate = Playdate.new(playdate_params)
      flash[:notice] = "De nieuwe speeldag is toegevoegd." if @playdate.save
      respond_with @playdate, location: playdates_path
    else
      @period = (params[:period] || PERIOD_THIS_MONTH).to_i
      @daytype = (params[:daytype] || DAY_SATURDAY).to_i
      save_new_range(@period, @daytype)
    end
  end

  def destroy
    @playdate = Playdate.find(params[:id])
    flash[:notice] = "De speeldag is verwijderd." if @playdate.destroy
    respond_with @playdate, location: playdates_path
  end

  def prune
    Playdate.irrelevant.each(&:destroy)
    flash[:notice] = "Oude speeldagen zijn opgeruimd."
    redirect_to playdates_path
  end

  private

  def save_new_range(period, daytype)
    unless [DAY_SATURDAY, DAY_FRIDAY].include?(daytype)
      flash[:notice] = "Invalid day!"
      render :new
      return
    end
    unless [PERIOD_THIS_MONTH, PERIOD_NEXT_MONTH].include?(period)
      flash[:notice] = "Invalid period!"
      render :new
      return
    end

    count = Playdate.make_new_range(period, daytype)

    if count > 0
      flash[:notice] = "Saved #{count}."
      redirect_to action: "index"
    else
      flash[:notice] = "Er zijn geen nieuwe datums toegevoegd."
      render :new
    end
  end

  def playdate_params
    params.require(:playdate).permit(:day)
  end
end
