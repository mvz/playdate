# frozen_string_literal: true

class CredentialsController < ApplicationController
  before_action :authorize

  def edit
    @player = current_user
  end

  def update
    @player = current_user
    if @player.update(player_params)
      redirect_to(controller: "main", action: "index")
    else
      render "edit", status: :unprocessable_entity
    end
  end

  private

  def player_params
    params.require(:player).permit(:password, :password_confirmation)
  end
end
