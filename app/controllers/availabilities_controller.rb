class AvailabilitiesController < ApplicationController
  before_filter :authorize
  verify :only => [ 'show', 'edit', 'destroy' ],
         :params => :id,
         :add_flash => { :notice => 'Missing availability ID.' },
         :redirect_to => { :action => 'list' }

  def destroy
    if request.post?
      Availability.find(params[:id]).destroy
      flash[:notice] = 'The availability was successfully destroyed.'
      redirect_to :action => 'list'
    else
      flash[:notice] = 'Click Destroy to destroy the availability.'
      redirect_to :action => 'edit', :id => params[:id]
    end
  end

  def edit
    @availability = Availability.find(params[:id])
    if request.post?
      if @availability.update_attributes(params[:availability])
        flash[:notice] = 'The availability was successfully edited.'
        redirect_to :action => 'show', :id => @availability
      end
    end
  end

  def list
    @availability_pages, @availabilities = paginate(:availabilities)
  end

  def new
    if request.post?
      @availability = Availability.new(params[:availability])
      if @availability.save
        flash[:notice] = 'A new availability was successfully added.'
        redirect_to :action => 'list'
      end
    else
      @availability = Availability.new
    end
  end

  def show
    @availability = Availability.find(params[:id])
  end
end
