$: << './lib'
$: << '../travis-worker/lib'

require 'bundler/setup'

require 'travis/guest-api/server'

$stdout.sync = true
$stderr.sync = true

def handle_payload(payload)
  puts "Got payload: #{payload.inspect}"
end

s1 = Travis::GuestApi::Server.new(1, &method(:handle_payload)).start
s2 = Travis::GuestApi::Server.new(2, &method(:handle_payload)).start

#300.times do |i|
#  Travis::GuestApi::Server.new(3 + i, &method(:handle_payload)).start
#end

puts "s1 is running on port: #{s1.port}"
puts "s2 is running on port: #{s2.port}"

sleep 5
puts 'goinng to stop s2 instance'
s2.stop

s1.server_thread.join
