require 'travis/guest-api'
require 'travis/guest-api/app/endpoint'

class Travis::GuestApi::App::Endpoint
  class Attachments < Travis::GuestApi::App::Endpoint

    post '/attachments' do
      halt 422, { error: 'No file uploaded.'}.to_json unless params[:file]

      redirect to(Travis::GuestApi.config.attachment_service_URL)
    end

  end
end
