class AvailabilitiesController < ApplicationController
  before_filter :authorize_admin
  before_filter :check_playdate_id
  before_filter :check_availability_id, :only => [ 'show', 'edit', 'destroy' ]
  #verify :only => [ 'show', 'edit', 'destroy' ],
  #       :params => :availability_id,
  #       :add_flash => { :notice => 'Missing availability ID.' },
  #       :redirect_to => { :controller => 'playdates', :action => 'list' }

  # TODO: Can we get rid of all these?
  def destroy
    if request.post?
      Availability.find(params[:availability_id]).destroy
      flash[:notice] = 'The availability was successfully destroyed.'
      redirect_to_playdate_view
    else
      flash[:notice] = 'Click Destroy to destroy the availability.'
      redirect_to :action => 'edit',
        :availability_id => params[:availability_id],
        :playdate_id => params[:playdate_id]
    end
  end

  def edit
    @availability = Availability.find(params[:availability_id])
    if request.post?
      if @availability.update_attributes(params[:availability])
        flash[:notice] = 'The availability was successfully edited.'
        redirect_to_playdate_view
      end
    end
  end

  def new
    if request.post?
      @availability = Playdate.find(params[:playdate_id]
                                   ).availabilities.build(params[:availability])
      if @availability.save
        flash[:notice] = 'A new availability was successfully added.'
        redirect_to_playdate_view
      end
    else
      @availability = Availability.new
    end
  end

  def list
    redirect_to_playdate_view
  end

  def show
    @availability = Availability.find(params[:availability_id])
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
    if params[:availability_id].nil?
      flash[:notice] = "Geen beschikbaarheid opgegeven"
      redirect_to_playdate_view
      return false
    end
    av = Availability.find(params[:availability_id])
    unless av.playdate_id.to_s == params[:playdate_id]
      flash[:notice] = "Beschikbaarheid niet gevonden"
      redirect_to_playdate_view
      return false
    end
    return true
  end
end
