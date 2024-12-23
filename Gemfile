# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.2.1"
# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.0"
# Use Puma as the app server
gem "puma", "~> 6.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 2.1.0"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.6"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3.4"

gem "dynamic_form", "~> 1.3.1"
gem "propshaft", "~> 1.1.0"
gem "responders", "~> 3.0"
gem "will_paginate", "~> 4.0.0"

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.3", require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  gem "rspec-rails", "~> 7.0"
end

group :development do
  gem "listen", "~> 3.9.0"
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem "web-console", "~> 4.0"

  gem "erb_lint", "~> 0.7.0", require: false
  gem "i18n-tasks", ["~> 1.0", ">= 1.0.13"], require: false
  gem "rubocop", "~> 1.63", require: false
  gem "rubocop-capybara", "~> 2.20", require: false
  gem "rubocop-performance", "~> 1.21", require: false
  gem "rubocop-rails", "~> 2.24", require: false
  gem "rubocop-rspec", "~> 3.0", require: false
  gem "rubocop-rspec_rails", "~> 2.30", require: false
end

group :test do
  gem "capybara", "~> 3.38", require: false
  gem "launchy", "~> 3.0"
  gem "rails-controller-testing", "~> 1.0"
  gem "selenium-webdriver", "~> 4.1", require: false
  gem "shoulda-matchers", "~> 6.0"
  gem "simplecov", require: false
  gem "timecop", "~> 0.9.5"
end
