# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'travis-guest-api/version'

Gem::Specification.new do |s|
  s.name         = "travis-guest-api"
  s.description  = "Implements API accessible from Gest's Masine from the test."
  s.authors      = ["Lukáš Svoboda"]
  s.summary      = "Guest API for Travis"
  s.email        = "lukas.svoboda@gmail.com"
  s.homepage     = "https://github.com/lksv/travis-guest-api"
  s.version      = TravisGuestApi::VERSION
  s.licenses = ['MIT']

  s.add_dependency 'rake'
  s.add_dependency 'travis-config',     '~> 0.1.0'
  s.add_dependency 'multi_json'

  s.files        = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

end
