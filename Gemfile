# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

gem 'rails', '7.1.3.2'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'tzinfo-data', platforms: %i[jruby]
gem 'bootsnap', require: false
gem 'blueprinter'
gem 'devise', '~> 4.2'
gem 'devise-jwt', '~> 0.11.0'
gem 'discard', '~> 1.4.0'
gem 'rack-cors', '~> 2.0.2'
gem 'sidekiq'
gem 'sidekiq-scheduler', '~> 5.0', '>= 5.0.3'

group :development, :test do
  gem 'annotate', '~> 3.0'
  gem 'debug', platforms: %i[mri]
  gem 'factory_bot', '~> 6.3'
  gem 'faker', '~> 3.2.1'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov', '~> 0.22'
end

group :test do
  gem 'rspec-sidekiq', '~> 3.1'
end
