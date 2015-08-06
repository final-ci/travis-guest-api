require 'travis/guest-api/app'
require 'travis/guest-api/app/base'

class Travis::GuestApi::App
  class Middleware
    class Rewrite < Base

      before '/jobs/:job_id/*' do
        rewrite_job_id_part
      end

      def rewrite_job_id_part
        v1_jobs_url_segment = %r{\A/jobs/(\d+)(?=/)}
        halt 422, { error: 'Job_id specified in both URL and body but they do not match!' }.to_json if env['job_id'] && (env['job_id'] != params['job_id'].to_i)
        env['PATH_INFO'].sub!(v1_jobs_url_segment, '')
        env['job_id'] = $1
      end
    end
  end
end
