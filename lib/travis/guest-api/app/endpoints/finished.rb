require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Finished < Travis::GuestApi::App::Base

    before do
      @msg_handler = env['msg_handler']
    end

    post '/finished' do
      payload = JSON.parse(request.body.read).slice('job_id', 'message')
      @msg_handler.call(event: 'finished')
      { success: true }.to_json
    end

  end
end
