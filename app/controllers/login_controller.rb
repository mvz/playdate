class LoginController < ApplicationController
  before_filter :authorize, :except => :login

  def login
    if request.post?
      player = Player.authenticate(params[:name], params[:password])
      if player
        session[:user_id] = player.id
        redirect_to(:controller => "main", :action => "index")
      else
        flash.now[:notice] = "Inloggen mislukt"
      end
    end
  end

  def logout
    if request.post?
      session[:user_id] = nil
      redirect_to(:action => "login")
    end
  end

  def edit
    @player = current_user
    if request.post?
      if @player.update_attributes(params[:player])
        redirect_to(:controller => "main", :action => "index")
      end
    end
  end
end
