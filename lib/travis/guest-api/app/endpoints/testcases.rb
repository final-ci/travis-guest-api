require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class TestCases < Travis::GuestApi::App::Base

    before do
      @job_id = env['job_id']
      @reporter = env['reporter']
    end

    #calls TestStepResult.write_result through amqp
    post '/testcases' do
      payload = JSON.parse(request.body.read)
      halt 422, { error: 'Keys name, classname, result are mandatory!' }.to_json unless
        payload['name'] and payload['classname'] and payload['result']
      payload['uuid'] = SecureRandom.uuid
      sanitized_payload = payload.slice('uuid', 'name', 'classname', 'result', 'duration', 'test_data')
      @reporter.send_tresult(@job_id, sanitized_payload)
      #Cache.put(@job_id,payload['uuid'], sanitized_payload)
    end

    get 'testcases/:id' do
      #Cache.get(@job_id, params[:id])
    end

    put 'testcases/:id' do
      halt 422, { error: 'Keys name, classname are mandator!' }.to_json unless
        params['name'] and params['classname']
      sanitized_payload = params.slice('id', 'name', 'classname', 'result', 'duration', 'test_data')
      @reporter.send_tresult_update(@job_id, sanitized_payload)
      #Cache.put(@job_id,payload['id'], sanitized_payload)
    end

  end
end
