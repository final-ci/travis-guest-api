require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Steps < Travis::GuestApi::App::Base
    before do
      @job_id = env['job_id']
      @reporter = env['reporter']
    end

    post '/steps' do
      steps = env['rack.parser.result']
      steps = [ params ] unless (Array === env['rack.parser.result'])

      steps.map! do |step|

        halt 422, {
          error: 'Keys name, classname are mandatory!'
        }.to_json unless !step.nil? && step['name'] && step['classname']
        halt 422, {
          error: 'UUID cannot be set!'
        } if step['uuid']

        step['uuid'] = SecureRandom.uuid
        step.slice(
          'uuid',
          'name',
          'position',
          'classname',
          'class_position',
          'result',
          'duration',
          'test_data'
        )
      end

      @reporter.send_tresult(@job_id, steps)
      steps.each do |step|
        Travis::GuestApi.cache.set(@job_id, step['uuid'], step)
      end
      steps = steps.first if !(Array === env['rack.parser.result'])
      steps.to_json
    end

    get '/steps/:uuid' do
      cached_step = Travis::GuestApi.cache.get(@job_id, params[:uuid])
      halt 403, error: 'Requested step could not be found.' unless cached_step
      cached_step.to_json
    end

    # Updates step result
    # it sends updated step_result to the reported (e.g. to the AMQP queue)
    #
    # the request could be Hash or Array.
    # Array is used for update several test steps (bulk update).
    # In case of bulk update UUIDs has to be specified within each items
    # otherwise UUID should be specified in the route
    #
    put '/steps/?:uuid?' do
      steps = env['rack.parser.result']
      steps = [ params ] unless (Array === env['rack.parser.result'])

      steps.map! do |step|
        halt 403, {
          error: 'Properties name, position, classname, class_position are read-only!'
        }.to_json if step['name'] || step['classname'] || step['position'] || step['class_position']
        halt 422, {
          error: 'UUID is mandatory!'
        }.to_json unless step['uuid']

        step.slice(
          'uuid',
          'result',
          'duration',
          'test_data'
        )
      end

      steps.each do |step|
        cached_step = Travis::GuestApi.cache.get(@job_id, step['uuid'])
        halt 404, error: 'Requested step could not be found.' unless cached_step
      end

      @reporter.send_tresult_update(@job_id, steps)
      steps.map! do |step|
        Travis::GuestApi.cache.set(@job_id, step['uuid'], step)
      end
      steps = steps.first if !(Array === env['rack.parser.result'])
      steps.to_json
    end
  end
end
