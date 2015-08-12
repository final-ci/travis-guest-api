# A sample Gemfile
source "https://rubygems.org"

gemspec

#gem 'travis-support', github: 'travis-ci/travis-support'
gem 'travis-support', github: 'finalci/travis-support'
#gem 'travis-support', path: '../travis-support'
gem 'travis-config', '~> 0.1.0'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'rack-contrib',    github: 'rack/rack-contrib'
gem 'rack-parser', :require => 'rack/parser'

#gem 'celluloid'

gem 'metriks',         '0.9.9.6'
gem 'metriks-librato_metrics', github: 'eric/metriks-librato_metrics'

gem 'nokogiri'

group :test do
  gem 'rspec'
  gem 'faraday'
  gem 'json-schema'
  gem 'factory_girl',     '~> 2.6.0'
  gem 'database_cleaner', '~> 1.4.1'
end

platform :jruby do
  gem 'march_hare',     '~> 2.7.0'
end
gem 'puma'
