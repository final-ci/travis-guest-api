require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'bundler/setup'
require 'travis/guest-api/app'

ENV['RAILS_ENV'] = ENV['RACK_ENV'] = ENV['ENV'] = 'test'
