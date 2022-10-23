# frozen_string_literal: true

class PlaydatesController < ApplicationController
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
      @playdate.save
      respond_with @playdate, location: playdates_path
    else
      @period = (params[:period] || PERIOD_THIS_MONTH).to_i
      @daytype = (params[:daytype] || DAY_SATURDAY).to_i
      save_new_range(@period, @daytype)
    end
  end

  def destroy
    @playdate = Playdate.find(params[:id])
    @playdate.destroy
    respond_with @playdate, location: playdates_path
  end

  def prune
    Playdate.irrelevant.each(&:destroy)
    flash[:notice] = t(".notice")
    redirect_to playdates_path
  end

  private

  def save_new_range(period, daytype)
    unless [DAY_SATURDAY, DAY_FRIDAY].include?(daytype)
      flash.now[:notice] = t("playdates.alerts.invalid_day")
      render :new
      return
    end
    unless [PERIOD_THIS_MONTH, PERIOD_NEXT_MONTH].include?(period)
      flash.now[:notice] = t("playdates.alerts.invalid_period")
      render :new
      return
    end

    count = Playdate.make_new_range(period, daytype)

    if count > 0
      flash[:notice] = t("playdates.notices.saved_new_range", count: count)
      redirect_to action: "index"
    else
      flash.now[:notice] = t("playdates.notices.saved_none")
      render :new
    end
  end

  def playdate_params
    params.require(:playdate).permit(:day)
  end
end
