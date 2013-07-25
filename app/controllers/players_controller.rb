class PlayersController < ApplicationController
  before_filter :authorize_admin

  def index
    @players = Player.paginate(:page => params[:page])
  end

  def new
    @player = Player.new
  end

  def edit
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      flash[:notice] = 'Player was successfully created.'
      redirect_to(players_url)
    else
      render :new
    end
  end

  def update
    @player = Player.find(params[:id])

    if @player.update_attributes(player_params)
      flash[:notice] = 'Player was successfully updated.'
      redirect_to(players_url)
    else
      render :edit
    end
  end

  def destroy
    @player = Player.find(params[:id])

    if @player == @current_user
      flash[:notice] = 'Cannot delete yourself'
      redirect_to(players_url)
    else
      if request.post?
        @player.availabilities.each { |av| av.destroy }
        @player.destroy
        redirect_to(players_url)
      else
        flash[:notice] = 'Kies Verwijderen om de speler te verwijderen'
        redirect_to(edit_player_url(@player))
      end
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :password, :password_confirmation)
  end
end
