class PlaydatesController < ApplicationController
  before_filter :authorize
  verify :only => [ 'show', 'edit', 'destroy' ],
         :params => :id,
         :add_flash => { :notice => 'Missing playdate ID.' },
         :redirect_to => { :action => 'list' }

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
    if request.post?
      @playdate = Playdate.new(params[:playdate])
      if @playdate.save
        flash[:notice] = 'A new playdate was successfully added.'
        redirect_to :action => 'list'
      end
    else
      @playdate = Playdate.new
    end
  end

  def show
    @playdate = Playdate.find(params[:id])
  end
end
