require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Started < Travis::GuestApi::App::Base

    before do
      @msg_handler = env['msg_handler']
    end

    post '/started' do
      @msg_handler.call(event: 'started')
      { success: true }.to_json
    end

  end
end
