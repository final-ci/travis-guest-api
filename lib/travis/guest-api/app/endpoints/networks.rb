require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Networks < Travis::GuestApi::App::Base

    post '/networks' do
       halt 501, { error: 'Tell Lukas to implement it.'}.to_json
    end

    delete 'networks/:network_id' do
      halt 501, { error: 'Tell @panjan to implement it.'}.to_json
    end

  end
end
