require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
    class Home < Travis::GuestApi::App::Base

      get '/' do
        content_type :text
        "Guest API, see docs"
      end

  end
end
