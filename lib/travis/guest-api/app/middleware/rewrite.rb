require 'spec_helper'
require 'travis/guest-api/app/base'
require "sinatra/namespace"
require 'ostruct'
require 'rack/test'

class Travis::GuestApi::App::Middleware
  class Rewrite < Travis::GuestApi::App::Base

    register Sinatra::Namespace

    V1_PREFIX = '/api/v1'
    V2_PREFIX = '/api/v2'

    namespace V1_PREFIX do
      before '/jobs/:job_id/*' do
        rewrite_job_id_part(params[:job_id].to_i)
      end

      before '/machines/logs/message' do
        rewrite_logs_part_v1
      end
    end

    def rewrite_job_id_part(job_id)
      if env['job_id'] && (env['job_id'] != job_id)
        halt 422, { error: 'Job_id specified in both URL and body but they do not match!' }.to_json
      end

      jobs_url_segment = %r{\A#{V1_PREFIX}/jobs/(\d+)(?=/)}
      env['PATH_INFO'].sub!(jobs_url_segment, V2_PREFIX)
      env['job_id'] = job_id
    end

    def rewrite_logs_part_v1
      env['PATH_INFO'] = "#{V2_PREFIX}/logs"
      halt 422, { error: 'x-MachineId must be specified in form data. '}.to_json unless env['x-MachineId']
      request.update_param 'job_id', env.delete('x-MachineId')
      request.update_param 'message', request.delete_param('messageText')
    end

  end
end
