# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.1"
# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"

gem "dynamic_form"
gem "responders", "~> 3.0"
gem "sprockets-rails", "~> 3.4.2"
gem "will_paginate", "~> 3.3.0"

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.9.0", require: false
gem "psych", "~> 4.0", require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem "listen", "~> 3.7.0"
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem "web-console", "~> 4.0"

  gem "rubocop", "~> 1.24.0", require: false
  gem "rubocop-minitest", "~> 0.17.0", require: false
  gem "rubocop-performance", "~> 1.13.0", require: false
  gem "rubocop-rails", "~> 2.13.0", require: false
end

gem "blind", group: :test
gem "minitest", "~> 5.12", group: :test
gem "minitest-spec-rails", "~> 6.1.0", group: :test
gem "simplecov", group: :test, require: false

gem "rails-controller-testing", "~> 1.0", group: :test
