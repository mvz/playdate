# frozen_string_literal: true

class RangeController < ApplicationController
  before_action :authorize

  def new
    # Show confirmation page
  end

  def create
    last_date = Playdate.last.day
    today = Time.zone.today
    last_date = today if last_date < today

    period = last_date + 7 > today.end_of_month ? 2 : 1

    count = Playdate.make_new_range(period, PlaydatesController::DAY_SATURDAY)
    count += Playdate.make_new_range(period, PlaydatesController::DAY_FRIDAY)
    flash[:notice] = if count > 0
                       'Data toegevoegd'
                     else
                       'Geen data toegevoegd'
                     end
    redirect_to root_path
  end
end
