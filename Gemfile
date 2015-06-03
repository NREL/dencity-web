source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.10'

# Use jdbcsqlite3 as the database for Active Record
# gem 'activerecord-jdbcsqlite3-adapter'
# MongoDB Adapter
gem 'mongoid', '~> 4.0.2'
# gem 'mongoid', git: 'git://github.com/mongoid/mongoid.git'

# JSON parsing and conversion
gem 'multi_json'

# XLSX parsing
gem 'roo'

# user auth, permissions, and mail
gem 'devise'
gem 'cancancan', '~> 1.9'
gem 'role_model'
gem 'mailgunner', '~> 2.2.1'

# pagination
gem 'will_paginate', '~> 3.0'

# HTTP requests
gem 'rest-client'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.1.1'
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
gem 'sunspot_rails'
gem 'sunspot_mongo'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'capistrano'
  gem 'sunspot_solr'
end

platforms :jruby do
  gem 'puma'
end
