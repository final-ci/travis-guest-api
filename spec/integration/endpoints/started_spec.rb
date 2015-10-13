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

    describe 'POST /started' do
      it 'call callback with event: started' do
        expect(callback).to receive(:call).with(
          job_id: 1,
          event: 'started',
          reporter: reporter
        )

        post '/api/v2/started', {}.to_json, "CONTENT_TYPE" => "application/json"
        expect(last_response.status).to eq(200)
      end
    end

  end
end
