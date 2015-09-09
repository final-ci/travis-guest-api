require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoint
  class Uptime < Travis::GuestApi::App::Base

    get '/uptime' do
      status 204
    end

  end
end
