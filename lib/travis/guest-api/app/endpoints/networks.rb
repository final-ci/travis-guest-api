require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Networks < Travis::GuestApi::App::Base

    post '/networks' do #plural in not correct here :-(
       halt 501, { error: 'Tell Lukas to implement it.'}.to_json
    end

  end
end
