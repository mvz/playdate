# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'

ActiveSupport::TestCase.class_eval do
  # Run tests in parallel with specified workers
  # Disabled for now. See https://github.com/metaskills/minitest-spec-rails/issues/94.
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
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
