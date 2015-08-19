$: << './lib'
require 'bundler/setup'
require 'travis/guest-api/server'

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

s1 = Travis::GuestApi::Server.new(nil, &method(:handle_payload)).start
s1.server_thread.join
