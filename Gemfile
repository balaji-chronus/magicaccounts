source 'http://rubygems.org'

gem 'rails', '3.2.6'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omnicontacts'
# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql'
gem 'mysql2', "~> 0.3.11"


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', ">= 3.2"
  gem 'uglifier'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
  gem 'sass-rails', '>= 3.2'
  gem 'less-rails'
  gem 'twitter-bootswatch-rails', '~> 3.0.0'
  gem 'twitter-bootswatch-rails-helpers'
  gem "font-awesome-rails"
  gem 'ejs'
end

gem 'client_side_validations'
gem 'will_paginate', '> 3.0'
gem "validates_existence", ">= 0.4"
gem "cancan"
gem "googlecharts", :require => "gchart"
gem 'minitest'
gem "select2-rails"
gem 'acts-as-taggable-on'
gem 'debugger'
gem 'gravatar_image_tag'
gem 'therubyracer'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19'

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  
end

group :production do
  gem 'thin'
  gem 'rack-google_analytics', :require => "rack/google_analytics"
end