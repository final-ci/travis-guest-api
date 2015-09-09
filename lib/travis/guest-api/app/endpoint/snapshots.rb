require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
  class Snapshots < Travis::GuestApi::App::Endpoint

    get '/snapshots' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

    post '/snapshots' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

    get '/snapshots/:id/revert' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

  end
end
