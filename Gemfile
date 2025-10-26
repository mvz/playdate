# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.3.1"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 2.2.0"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.6"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3.4"

# Use Active Model has_secure_password
# [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "responders", "~> 3.0"
gem "will_paginate", "~> 4.0.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.3", require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  gem "rspec-rails", "~> 8.0"
end

group :development do
  gem "listen", "~> 3.9.0"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.0"

  gem "erb_lint", "~> 0.9.0", require: false
  gem "i18n-tasks", ["~> 1.0", ">= 1.0.13"], require: false
  gem "rubocop", "~> 1.80", require: false
  gem "rubocop-capybara", "~> 2.22", require: false
  gem "rubocop-performance", "~> 1.25", require: false
  gem "rubocop-rails", "~> 2.33", require: false
  gem "rubocop-rspec", "~> 3.7", require: false
  gem "rubocop-rspec_rails", "~> 2.31", require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.38", require: false
  gem "selenium-webdriver", "~> 4.1", require: false

  gem "launchy", "~> 3.0"
  gem "rails-controller-testing", "~> 1.0"
  gem "shoulda-matchers", "~> 6.0"
  gem "simplecov", require: false
  gem "timecop", "~> 0.9.5"
end
