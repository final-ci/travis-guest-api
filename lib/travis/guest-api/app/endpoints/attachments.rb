require 'travis/guest_api'
require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Attachments < Travis::GuestApi::App::Base

    post '/attachments' do
      halt 422, { error: 'No file uploaded.'} unless params[:file]

      redirect to(Travis::GuestApi.config.attachment_service_URL)
    end

  end
end
