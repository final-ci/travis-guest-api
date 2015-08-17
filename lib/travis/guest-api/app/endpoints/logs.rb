require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Logs < Travis::GuestApi::App::Base

    before do
      @reporter = env['reporter']
      @job_id = env['job_id'] ? env['job_id'] : params['job_id']
      halt 422, { error: 'Job ID must be specified.'} unless @job_id
    end

    post '/logs' do
      payload = params.slice('message')
      halt 422, { error: 'Key message and number must be passed'}.to_json unless payload['message']
      @reporter.send_log(@job_id, payload["message"])
      { success: true }.to_json
    end

  end
end
