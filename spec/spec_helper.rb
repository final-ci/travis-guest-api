#FIXME: needs to move Reporter here
$: << './lib'
$: << '../travis-worker/lib'

require 'bundler/setup'

ENV['RAILS_ENV'] = ENV['ENV'] = 'test'
