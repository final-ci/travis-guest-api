require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
  class Steps < Travis::GuestApi::App::Endpoint
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
        }.to_json if step['uuid']

        step['uuid'] = SecureRandom.uuid
        step['job_id'] = @job_id

        res = step.slice(
          'uuid',
          'job_id',
          'name',
          'position',
          'classname',
          'class_position',
          'result',
          'duration',
          'data',
          'test_data'
        )
        res['number'] = 0
        res
      end

      @reporter.send_tresult(@job_id, steps)
      steps.each do |step|
        Travis.logger.debug "Setting step #{@job_id.inspect}, #{step['uuid'].inspect} to #{step.inspect}"
        Travis::GuestApi.cache.set(@job_id, step['uuid'], step)
      end
      steps = steps.first if !(Array === env['rack.parser.result'])
      steps.to_json
    end

    get '/steps/:uuid' do
      cached_step = Travis::GuestApi.cache.get(@job_id, params[:uuid])
      halt 403, { error: 'Requested step could not be found.' }.to_json unless cached_step
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
          'data'
        )
      end

      not_found_uids = []
      steps.each do |step|
        cached_step = Travis::GuestApi.cache.get(@job_id, step['uuid'])
        not_found_uids << step['uuid'] unless cached_step
        step['number'] ||= ((cached_step || {})['number'] || 0)
        step['number'] += 1
      end

      unless not_found_uids.empty?
        msg = "Step(s) could not be found, UUIDs=#{not_found_uids.join(',')}"
        Travis.logger.error msg
        halt 404, { error: msg }.to_json
      end

      steps.map! do |step|
        result = Travis::GuestApi.cache.set(@job_id, step['uuid'], step)
        Travis.logger.debug "Updated step #{@job_id.inspect},#{step['uuid'].inspect} to: #{step.inspect}"
        result
      end
      @reporter.send_tresult_update(@job_id, steps)
      steps = steps.first if !(Array === env['rack.parser.result'])
      steps.to_json
    end
  end
end
