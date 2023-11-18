# frozen_string_literal: true

class SessionController < ApplicationController
  before_action :authorize, except: [:new, :create]

  def new
    # Just show login form
  end

  def edit
    # Just show logout form
  end

  def create
    player = Player.authenticate(params[:name], params[:password])
    if player
      session[:user_id] = player.id
      redirect_to(controller: "main", action: "index")
    else
      flash.now[:notice] = t(".failure")
      render "new", status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to(action: "new")
  end
end
