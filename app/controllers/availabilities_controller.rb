# frozen_string_literal: true

# Administrative controller for editing availabilities.
class AvailabilitiesController < ApplicationController
  before_action :authorize_admin
  before_action :load_resource, only: [:edit, :update, :destroy]
  before_action :load_playdate, only: [:new, :create]

  def new
    @availability = Availability.new
  end

  def edit
    @player = @availability.player
  end

  def create
    @availability = @playdate.availabilities.build(new_availability_params)
    @availability.save
    respond_with @availability, location: playdate_path(@playdate)
  end

  def update
    @availability.update(edit_availability_params)
    respond_with @availability, location: playdate_path(@playdate)
  end

  def destroy
    @availability.destroy
    respond_with @availability, location: playdate_path(@playdate)
  end

  private

  def edit_availability_params
    params.expect(availability: [:status])
  end

  def new_availability_params
    params.expect(availability: [:player_id, :status])
  end

  def load_resource
    load_playdate
    @availability = @playdate.availabilities.find(params[:id])
  end

  def load_playdate
    @playdate = Playdate.find(params[:playdate_id])
  end
end
