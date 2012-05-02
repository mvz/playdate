# Administrative controller for editing availabilities.
class AvailabilitiesController < ApplicationController
  before_filter :authorize_admin
  before_filter :check_playdate_id
  before_filter :check_availability_id, :only => [ 'show', 'edit', 'destroy' ]

  # TODO: Can we get rid of all these?
  def destroy
    if request.post?
      Availability.find(params[:id]).destroy
      flash[:notice] = 'The availability was successfully destroyed.'
      redirect_to_playdate_view
    else
      flash[:notice] = 'Click Destroy to destroy the availability.'
      redirect_to :action => 'edit',
        :id => params[:id],
        :playdate_id => params[:playdate_id]
    end
  end

  def edit
    @availability = Availability.find(params[:id])
    if request.post?
      if @availability.update_attributes(params[:availability])
        flash[:notice] = 'The availability was successfully edited.'
        redirect_to_playdate_view
      end
    end
  end

  def new
    @availability = Availability.new
  end

  def create
    if request.post?
      @availability = Playdate.find(params[:playdate_id]
                                   ).availabilities.build(params[:availability])
      if @availability.save
        flash[:notice] = 'A new availability was successfully added.'
        redirect_to_playdate_view
      end
    end
  end

  def index
    redirect_to_playdate_view
  end

  def show
    @availability = Availability.find(params[:id])
    @player = @availability.player
    @playdate = @availability.playdate
  end

  private

  def redirect_to_playdate_view
    redirect_to :controller => "playdates", :action => 'show', :id => params[:playdate_id]
  end

  def check_playdate_id
    if params[:playdate_id].nil?
      flash[:notice] = "Geen speeldatum opgegeven"
      redirect_to :controller => "playdates", :action => 'list'
      return false
    end
    return true
  end

  def check_availability_id
    check_availability_id_present && check_availability_found
  end

  def check_availability_id_present
    if params[:id].nil?
      flash[:notice] = "Geen beschikbaarheid opgegeven"
      redirect_to_playdate_view
      return false
    end
    true
  end

  def check_availability_found
    av = Availability.find(params[:id])
    unless av.playdate_id.to_s == params[:playdate_id].to_s
      flash[:notice] = "Beschikbaarheid niet gevonden"
      redirect_to_playdate_view
      return false
    end
    true
  end
end
