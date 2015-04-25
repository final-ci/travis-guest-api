$: << './lib'
$: << '../travis-worker/lib'

require 'bundler/setup'

require 'travis/guest-api/server'

$stdout.sync = true
$stderr.sync = true

def handle_payload(payload)
  puts "Prisel payload: #{payload.inspect}"
end

s1 = Travis::GuestApi::Server.new(1, &method(:handle_payload)).start
s2 = Travis::GuestApi::Server.new(2, &method(:handle_payload)).start

puts "servet1 bezi na portu: #{s1.port}"

sleep 5
puts 'stopuji 2'
s2.stop

s1.server_thread.join
