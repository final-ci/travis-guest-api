require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
    class Home < Travis::GuestApi::App::Endpoint

      get '/' do
        content_type :text
        "Guest API, see docs"
      end

  end
end
