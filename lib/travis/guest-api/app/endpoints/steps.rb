require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Steps < Travis::GuestApi::App::Base
    before do
      @job_id = env['job_id']
      @reporter = env['reporter']
    end

    post '/steps' do
      halt 422, {
        error: 'Keys name, classname, result are mandatory!'
      }.to_json unless params['name'] && params['classname'] && params['result']
      params['uuid'] = SecureRandom.uuid
      sanitized_payload = params.slice(
        'uuid',
        'name',
        'classname',
        'result',
        'duration',
        'test_data')
      @reporter.send_tresult(@job_id, sanitized_payload)
      Travis::GuestApi.cache.set(@job_id, params['uuid'], sanitized_payload)
      sanitized_payload.to_json
    end

    get '/steps/:uuid' do
      cached_step = Travis::GuestApi.cache.get(@job_id, params[:uuid])
      halt 403, error: 'Requested step could not be found.' unless cached_step
      cached_step.to_json
    end

    put '/steps/:uuid' do
      halt 403, {
        error: 'Properties "name" and "classname" are read-only.'
      }.to_json if params['name'] || params['classname']
      sanitized_payload = params.slice(
        'uuid',
        'result',
        'duration',
        'test_data')
      cached_step = Travis::GuestApi.cache.get(@job_id, sanitized_payload['uuid'])
      halt 403, error: 'Requested step could not be found.' unless cached_step
      @reporter.send_tresult_update(@job_id, sanitized_payload)
      cached_step = Travis::GuestApi.cache.set(@job_id, sanitized_payload['uuid'], sanitized_payload)
      cached_step.to_json
    end
  end
end
