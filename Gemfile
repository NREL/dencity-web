source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.9'

# Use jdbcsqlite3 as the database for Active Record
#gem 'activerecord-jdbcsqlite3-adapter'
# MongoDB Adapter
gem 'mongoid', git: 'git://github.com/mongoid/mongoid.git'

# JSON parsing and conversion
gem "multi_json"

# XLSX parsing
gem "roo"

# user auth & permissions
gem 'devise'
gem 'cancancan', '~> 1.9'
gem 'role_model'

# pagination
gem 'will_paginate', '~> 3.0'

# HTTP requests
gem "rest-client"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem "bootstrap-sass", '~> 3.1.1'
gem 'bootstrap_form'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyrhino'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Solr-based searching
gem "sunspot_rails"

# This github fork fixes compatibility with Mongoid 3 (by using
# Moped::BSON::ObjectId instead of BSON::ObjectId).
gem 'bson'
gem 'moped', github: 'mongoid/moped'
gem 'sunspot_mongoid2', github: 'hlegius/sunspot_mongoid2'
#gem "sunspot_mongo", :git => "https://github.com/jclosure/sunspot_mongo.git"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end


# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

group :development, :test do
  gem 'sunspot_solr'
  gem 'puma'
end
