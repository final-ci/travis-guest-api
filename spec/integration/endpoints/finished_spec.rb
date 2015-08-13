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

    describe 'POST /finished' do
      it 'call callback with event: finished' do
        expect(callback).to receive(:call).with(event: 'finished')

        response = post '/api/v2/finished', {}.to_json, "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(200)
      end
    end

  end
end
