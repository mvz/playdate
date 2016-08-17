source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.1.0'

gem 'dynamic_form'
gem 'haml'
gem 'responders', '~> 2.0'
gem 'will_paginate', '~> 3.1.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %>
  # anywhere in the code.
  gem 'web-console', '~> 3.1'
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use pry for rails console
  gem 'pry-rails'

  gem 'rubocop', '~> 0.42.0'
end

gem 'simplecov', group: :test, require: false
gem 'minitest-spec-rails', '~> 5.3', group: :test
gem 'blind', group: :test

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rails-controller-testing', '~> 0.1.1', group: :test
