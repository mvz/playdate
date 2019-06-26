# frozen_string_literal: true

class PlayersController < ApplicationController
  respond_to :html
  before_action :authorize_admin

  def index
    @players = Player.paginate(page: params[:page])
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

    flash[:notice] = 'Player was successfully updated.' if @player.update player_params
    respond_with @player, location: players_path
  end

  def destroy
    @player = Player.find(params[:id])

    if @player == current_user
      flash[:error] = 'Cannot delete yourself'
      redirect_to(players_url)
    else
      if @player.destroy
        flash[:notice] = 'Player was successfully destroyed.'
      else
        flash[:error] = 'Destroying the player failed.'
      end
      respond_with @player, location: players_path
    end
  end

  private

  def player_params
    params.require(:player).permit(:name,
                                   :full_name,
                                   :abbreviation,
                                   :is_admin,
                                   :default_status,
                                   :password,
                                   :password_confirmation)
  end
end
