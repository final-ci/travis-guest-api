require 'travis/guest-api/app/base'
require 'travis/guest-api/app'
require 'sinatra/base'

class Travis::GuestApi::App
  class Endpoint < Base

    # / and /uptime does not need job_id
    before /^(?!\/$|\/uptime)/ do
      if env['job_id'] && params['job_id'] && (env['job_id'] != params['job_id'].to_i)
        halt 422, {
          error: 'Job_id specified both on startup and '\
                 'in the request but they do not match!!!'
        }.to_json
      end
      @job_id = env['job_id']
      @job_id ||= params['job_id'].to_i if params['job_id']
      halt 422, { error: 'Job ID must be specified.'}.to_json unless @job_id
    end

  end
end
