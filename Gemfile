source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql'
gem 'mysql2', "~> 0.3.11"


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
  gem 'twitter-bootstrap-rails', "~> 2.0.3"
  gem 'jquery-rails'
  gem 'jquery-ui-rails'

end

gem 'jquery-rails'
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