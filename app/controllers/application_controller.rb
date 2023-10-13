# frozen_string_literal: true

require "application_responder"

# Main controller superclass.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  self.responder = ApplicationResponder
  respond_to :html

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
    flash[:notice] = t("application.notice.log_in_first")
    redirect_to(controller: "session", action: "new")
    false
  end

  def access_denied_no_admin
    flash[:notice] = t("application.notice.access_denied_no_admin")
    redirect_to(controller: "main", action: "index")
    false
  end
end
