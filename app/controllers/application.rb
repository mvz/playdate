# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  private
  def authorize
    get_current_user or access_denied_not_logged_in
  end
  def authorize_admin 
    ad = get_current_user
    unless ad
      access_denied_not_logged_in
    else
      ad.is_admin or access_denied_no_admin
    end
  end
  def get_current_user
    Player.find_by_id(session[:user_id])
  end
  def access_denied_not_logged_in
    flash[:notice] = "Please log in"
    redirect_to(:controller => "login", :action => "login")
  end
  def access_denied_no_admin
    flash[:notice] = "Access denied: You are not the administrator"
    redirect_to(:controller => "login", :action => "index")
  end
end
