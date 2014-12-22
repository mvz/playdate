# Main controller superclass.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
    flash[:notice] = 'Log eerst in om Playdate te gebruiken.'
    redirect_to(controller: 'login', action: 'login')
    false
  end

  def access_denied_no_admin
    flash[:notice] = 'Toegang geweigerd: Je bent geen beheerder.'
    redirect_to(controller: 'main', action: 'index')
    false
  end
end
