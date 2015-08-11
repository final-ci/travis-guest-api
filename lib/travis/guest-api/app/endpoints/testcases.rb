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
      @reporter.send_tresult(@job_id, payload.slice('name', 'classname', 'result', 'duration', 'test_data'))
    end

    put 'testcases/:id' do
      payload = JSON.parse(request.body.read)
      halt 422, { error: 'Keys name, classname are mandator!' }.to_json unless
        payload['name'] and payload['classname']
      @reporter.send_tresult_update(@job_id, payload.slice('name', 'classname', 'result', 'duration', 'test_data'))
    end

  end
end
