require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
  class Logs < Travis::GuestApi::App::Endpoint

    before do
      @reporter = env['reporter']
    end

    post '/logs' do
      halt 422, { error: 'Key message and number must be passed'}.to_json unless params['message']
      @reporter.send_log(@job_id, params["message"])
      { success: true }.to_json
    end

  end
end
