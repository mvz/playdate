# frozen_string_literal: true

class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder

  # Use status codes compatible with Turbo.
  self.error_status = :unprocessable_entity
  self.redirect_status = :see_other
end
