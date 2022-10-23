# frozen_string_literal: true

class PlayersController < ApplicationController
  before_action :authorize_admin

  def index
    @players = Player.paginate(page: params[:page])
  end

  def new
    @player = Player.new
  end

  def edit
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)
    flash[:notice] = t(".notice") if @player.save
    respond_with @player, location: players_path
  end

  def update
    @player = Player.find(params[:id])

    flash[:notice] = t(".notice") if @player.update player_params
    respond_with @player, location: players_path
  end

  def destroy
    @player = Player.find(params[:id])

    if @player == current_user
      flash[:alert] = t(".cannot_delete_self")
      redirect_to(players_url)
    else
      if @player.destroy
        flash[:notice] = t(".notice")
      else
        flash[:alert] = t(".failed")
      end
      respond_with @player, location: players_path
    end
  end

  private

  def player_params
    params.require(:player)
      .permit(
        :name,
        :full_name,
        :abbreviation,
        :is_admin,
        :default_status,
        :password,
        :password_confirmation
      )
  end
end
