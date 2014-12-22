class LoginController < ApplicationController
  before_action :authorize, except: :login

  def login
    if request.post?
      player = Player.authenticate(params[:name], params[:password])
      if player
        session[:user_id] = player.id
        redirect_to(controller: 'main', action: 'index')
      else
        flash.now[:notice] = 'Inloggen mislukt'
      end
    end
  end

  def logout
    if request.post?
      session[:user_id] = nil
      redirect_to(action: 'login')
    end
  end

  def edit
    @player = current_user
    if request.post?
      if @player.update_attributes(player_params)
        redirect_to(controller: 'main', action: 'index')
      end
    end
  end

  private

  def player_params
    params.require(:player).permit(:password, :password_confirmation)
  end
end
