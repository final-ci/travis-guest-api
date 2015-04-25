$: << './lib'
$: << '../travis-worker/lib'

require 'bundler/setup'

require 'travis/guest-api/app'

$stdout.sync = true

app = Travis::GuestApi::App.new(1) do |payload|
  puts "Prisel payload: #{payload.inspect}"
end

run app
