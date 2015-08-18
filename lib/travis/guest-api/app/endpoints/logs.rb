require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Logs < Travis::GuestApi::App::Base

    before do
      @reporter = env['reporter']
    end

    post '/logs' do
      payload = params.slice('message')
      halt 422, { error: 'Key message and number must be passed'}.to_json unless payload['message']
      @reporter.send_log(@job_id, payload["message"])
      { success: true }.to_json
    end

  end
end
