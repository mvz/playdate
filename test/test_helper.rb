# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'minitest/mock'

ActiveSupport::TestCase.class_eval do
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

ActionController::TestCase.class_eval do
  include Blind

  def assert_not_routed(options)
    assert_raises ActionController::UrlGenerationError do
      url = @controller.url_for options
      recognized_request_for url
    end
  end
end
