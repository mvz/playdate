class PlayersController < ApplicationController
  before_filter :authorize_admin

  def index
    @players = Player.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @players }
    end
  end

  def show
    @player = Player.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @player }
    end
  end

  def new
    @player = Player.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @player }
    end
  end

  def edit
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        flash[:notice] = 'Player was successfully created.'
        format.html { redirect_to(players_url) }
        format.xml  { render :xml => @player, :status => :created, :location => @player }
      else
        format.html { render :new }
        format.xml  { render :xml => @player.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @player = Player.find(params[:id])

    respond_to do |format|
      if @player.update_attributes(player_params)
        flash[:notice] = 'Player was successfully updated.'
        format.html { redirect_to(players_url) }
        format.xml  { head :ok }
      else
        format.html { render :edit }
        format.xml  { render :xml => @player.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @player = Player.find(params[:id])

    respond_to do |format|
      if @player == @current_user
        flash[:notice] = 'Cannot delete yourself'
        format.html { redirect_to(players_url) }
        format.xml  { head :unprocessable_entity }
      else
        if request.post?
          @player.availabilities.each { |av| av.destroy }
          @player.destroy
          format.html { redirect_to(players_url) }
          format.xml  { head :ok }
        else
          flash[:notice] = 'Kies Verwijderen om de speler te verwijderen'
          format.html { redirect_to(edit_player_url(@player)) }
          format.xml  { head :unprocessable_entity }
        end
      end
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :password, :password_confirmation)
  end
end
