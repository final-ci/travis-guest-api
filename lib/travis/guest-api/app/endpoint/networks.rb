require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
  class Networks < Travis::GuestApi::App::Endpoint

    post '/networks' do
       halt 501, { error: 'Tell Lukas to implement it.'}.to_json
    end

    delete 'networks/:network_id' do
      halt 501, { error: 'Tell @panjan to implement it.'}.to_json
    end

  end
end
