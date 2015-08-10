require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Middleware
  class Rewrite < Travis::GuestApi::App::Base

    before '/jobs/:job_id/*' do
      rewrite_job_id_part(params[:job_id].to_i)
    end

    def rewrite_job_id_part(job_id)
      v1_jobs_url_segment = %r{\A/jobs/(\d+)(?=/)}
      if env['job_id'] && (env['job_id'] != job_id)
        halt 422, { error: 'Job_id specified in both URL and body but they do not match!' }.to_json
      end
      env['PATH_INFO'].sub!(v1_jobs_url_segment, '')
      env['job_id'] = job_id
    end
  end
end
