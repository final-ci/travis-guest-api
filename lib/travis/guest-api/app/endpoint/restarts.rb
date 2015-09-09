require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
  class Restarts < Travis::GuestApi::App::Endpoint

    post '/restarts' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

    delete '/restarts' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

  end
end
