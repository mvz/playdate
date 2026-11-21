# frozen_string_literal: true

require "application_responder"

# Main controller superclass.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  self.responder = ApplicationResponder
  respond_to :html

  private

  def authorize_admin
    authenticate_player!
    current_player.is_admin or access_denied_no_admin
  end

  def access_denied_no_admin
    flash[:notice] = t("application.notice.access_denied_no_admin")
    redirect_to(controller: "main", action: "index")
    false
  end
end
