require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Restarts < Travis::GuestApi::App::Base

    post '/restarts' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

    delete '/restarts' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

  end
end
