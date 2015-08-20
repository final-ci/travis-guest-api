require 'travis/guest-api/app/base'

class Travis::GuestApi::App::Endpoints
  class Snapshots < Travis::GuestApi::App::Base

    get '/snapshots' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

    post '/snapshots' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

    get '/snapshots/:id/revert' do
      halt 501, { error: 'all your base are belong to us' }.to_json
    end

  end
end
