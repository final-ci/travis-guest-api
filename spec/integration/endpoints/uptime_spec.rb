require 'spec_helper'
require 'ostruct'

require 'travis/guest-api/app'
require 'rack/test'

module Travis::GuestApi
  describe App do
    include Rack::Test::Methods

    def app
      Travis::GuestApi::App.new(1, reporter, &callback)
    end

    let(:reporter) { double(:reporter) }
    let(:callback) { ->(x) { } }

    describe 'GET /uptime' do
      it 'returns 204' do
        response = get '/api/v2/uptime'
        expect(response.status).to eq(204)
      end
    end

  end
end
