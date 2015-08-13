require 'travis/guest_api'
require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Attachments < Travis::GuestApi::App::Base

    before do
      @job_id = env['job_id'] ? env['job_id'] : params['job_id']
      halt 422, { error: 'Job ID must be specified.'} unless @job_id
    end

    post '/attachments' do
      halt 422, { error: 'No file uploaded.'} unless params[:file]
      halt 422, { error: 'Filename must be specified.' } if
        params[:file][:filename].nil? || params[:file][:filename].empty?

      redirect to(Travis::GuestApi.config.attachment_service_URL)
    end

  end
end
