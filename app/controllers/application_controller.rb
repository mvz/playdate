# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  private

  def authorize
    @current_user = current_user
    @current_user or access_denied_not_logged_in
  end

  def authorize_admin
    authorize or return false
    @current_user.is_admin or access_denied_no_admin
  end

  def current_user
    Player.find_by_id(session[:user_id])
  end

  def access_denied_not_logged_in
    flash[:notice] = "Log eerst in om Playdate te gebruiken."
    redirect_to(:controller => "login", :action => "login")
    return false
  end

  def access_denied_no_admin
    flash[:notice] = "Toegang geweigerd: Je bent geen beheerder."
    redirect_to(:controller => "main", :action => "index")
    return false
  end
end
