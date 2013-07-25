class PlayersController < ApplicationController
  respond_to :html
  before_filter :authorize_admin

  def index
    @players = Player.paginate(:page => params[:page])
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    flash[:notice] = 'Player was successfully created.' if @player.save
    respond_with @player, location: players_path
  end

  def edit
    @player = Player.find(params[:id])
  end

  def update
    @player = Player.find(params[:id])

    if @player.update_attributes player_params
      flash[:notice] = 'Player was successfully updated.'
    end
    respond_with @player, location: players_path
  end

  def destroy
    @player = Player.find(params[:id])

    if @player == @current_user
      flash[:error] = 'Cannot delete yourself'
      redirect_to(players_url)
    else
      @player.availabilities.each { |av| av.destroy }
      if @player.destroy
        flash[:notice] = 'Player was successfully destroyed.'
      end
      respond_with @player
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :password, :password_confirmation)
  end
end
