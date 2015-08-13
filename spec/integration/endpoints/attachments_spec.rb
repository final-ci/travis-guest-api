require 'spec_helper'
require 'travis/guest_api'

require 'ostruct'
require 'travis/guest-api/app'
require 'rack/test'
require 'rspec'

module Travis::GuestApi
  describe App do
    include Rack::Test::Methods

    def app
      Travis::GuestApi::App.new(1, reporter, &callback)
    end

    let(:reporter) { double(:reporter) }
    let(:callback) { ->(x) { } }

    describe 'POST /attachments' do
      it 'returns 422 when time not specified' do
        response = post "/api/v2/attachments",
          { indent: 666 }.to_json,
          "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(422)
      end

      it 'returns 422 when indent not specified' do
        response = post "/api/v2/attachments",
          { localTime: '15:42 8/13/2015' }.to_json,
          "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(422)
      end

      it 'redirects to attachment service' do
        response = post "/api/v2/attachments",
          { localTime: '15:42 8/13/2015', indent: 666 }.to_json,
          "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(302)
        expect(response).to redirect_to(Travis::GuestApi.config.attachment_service_URL)
      end
    end

  end
end
