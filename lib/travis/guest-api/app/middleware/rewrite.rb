require 'travis/guest-api/app/base'
require "sinatra/namespace"
require 'ostruct'
require 'rack/test'

class Travis::GuestApi::App::Middleware
  class Rewrite < Travis::GuestApi::App::Base

    register Sinatra::Namespace

    V1_PREFIX = '/api/v1'
    V2_PREFIX = '/api/v2'
    JOB_ID_PATTERN = %r{/api/v\d+/jobs/(\d+)}

    before JOB_ID_PATTERN do |job_id|
      rewrite_job_id_part(job_id.to_i)
    end

    namespace V1_PREFIX do
      before '/machines/logs/message' do
        rewrite_logs_v1
      end

      before '/machines/logs/attachement' do
        rewrite_attachments_v1
      end

      before '/machines/networks' do
        rewrite_networks_v1
      end
    end

    def rewrite_job_id_part(job_id)
      if env['job_id'] && (env['job_id'] != job_id)
        halt 422, { error: 'Job_id specified in both URL and body but they do not match!' }.to_json
      end

      env['PATH_INFO'].sub!(JOB_ID_PATTERN, V2_PREFIX)
      env['job_id'] = job_id
    end

    def rewrite_logs_v1
      env['PATH_INFO'] = "#{V2_PREFIX}/logs"
      unless env['x-MachineId']
        halt 422, { error: 'x-MachineId must be specified in form data. '}.to_json
      end
      request.update_param 'job_id', env.delete('x-MachineId')
      request.update_param 'message', request.delete_param('messageText')
    end

    def rewrite_attachments_v1
      env['PATH_INFO'] = "#{V2_PREFIX}/attachments"
    end

    def rewrite_networks_v1
      env['PATH_INFO'] = "#{V2_PREFIX}/networks"
    end

  end
end
