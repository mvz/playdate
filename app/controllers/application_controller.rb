# frozen_string_literal: true

# Main controller superclass.
class ApplicationController < ActionController::Base
  before_action :load_current_user

  helper_method :current_user

  private

  def authorize
    current_user or access_denied_not_logged_in
  end

  def authorize_admin
    authorize or return false
    current_user.is_admin or access_denied_no_admin
  end

  def load_current_user
    @current_user = Player.find_by(id: session[:user_id])
  end

  attr_reader :current_user

  def access_denied_not_logged_in
    flash[:notice] = "Log eerst in om Playdate te gebruiken."
    redirect_to(controller: "session", action: "new")
    false
  end

  def access_denied_no_admin
    flash[:notice] = "Toegang geweigerd: Je bent geen beheerder."
    redirect_to(controller: "main", action: "index")
    false
  end
end
