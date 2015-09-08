#!/usr/bin/ruby

$: << './lib'
require 'bundler/setup'
require 'travis/guest-api/server'
require 'travis/guest-api/reporter'
require 'travis/support/amqp'

$stdout.sync = true
$stderr.sync = true

def handle_payload(payload)
  puts "Got payload: #{payload.inspect}"
  case payload[:event]
  when 'finished'
    halt 501, { error: 'all your base are belong to us' }.to_json
  when 'started'
    halt 501, { error: 'all your base are belong to us' }.to_json
  end
end

options = {
  Port: ENV['GUEST_API_PORT'] || 9292,
  Threads: ENV['GUEST_API_THREADS'] || '0:16'
}
reporter = Travis::GuestApi::Reporter.new(
  'standalone-reporter',
  Travis::Amqp::Publisher.jobs('builds', unique_channel: true, dont_retry: true),
  Travis::Amqp::Publisher.jobs('logs', unique_channel: true, dont_retry: true),
  Travis::Amqp::Publisher.jobs('test_results', unique_channel: true, dont_retry: true)
)

server = Travis::GuestApi::Server.new(nil, reporter, options, &method(:handle_payload)).start
Travis.logger.info "Server started"
server.server_thread.join
