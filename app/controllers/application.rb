# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  private
  def authorize
    @current_user = current_user
    @current_user or access_denied_not_logged_in
  end
  def authorize_admin 
    @current_user = current_user
    unless @current_user
      access_denied_not_logged_in
    else
      @current_user.is_admin or access_denied_no_admin
    end
  end
  def current_user
    Player.find_by_id(session[:user_id])
  end
  def access_denied_not_logged_in
    flash[:notice] = "Log eerst in om Playdate te gebruiken."
    redirect_to(:controller => "login", :action => "login")
  end
  def access_denied_no_admin
    flash[:notice] = "Toegang geweigerd: Je bent geen beheerder."
    redirect_to(:controller => "login", :action => "index")
  end
end
