require 'spec_helper'
require 'ostruct'

require 'rack/test'

module Travis::GuestApi
  describe App do
    include Rack::Test::Methods

    def app
      Travis::GuestApi::App.new(1, reporter, &callback)
    end

    let(:reporter) { double(:reporter) }
    let(:callback) { ->(x) { } }

    describe 'POST /logs' do
      let(:post_data1) { { job_id: 1, message: 'my message1' } }
      let(:post_data2) { { job_id: 1, message: 'my message2' } }

      it 'sends data to pusher' do
        expect(reporter).to receive(:send_log).with(1, post_data1[:message])
        expect(reporter).to receive(:send_log).with(1, post_data2[:message])

        response = post '/api/v2/logs', post_data1.to_json, "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(200)

        response = post '/api/v2/logs', post_data2.to_json, "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(200)
      end

      it 'responds with 422 when message is missing' do
        response = post '/api/v2/logs', { job_id: 1 }.to_json, "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(422)
      end

      it 'responds with 422 on job_id mismatch' do
        response = post '/api/v2/logs', { job_id: 2 }.to_json, "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(422)
      end
    end

    describe 'correctly rewrites form v1' do
      #post '/api/v1/messages/logs/message',
    end

    describe 'POST /jobs/:job_id/logs' do
      it 'responds with 422 when passed job_id is wrong' do
        response = post '/api/v1/jobs/2/logs', { job_id: 1 }.to_json, "CONTENT_TYPE" => "application/json"
        expect(response.status).to eq(422)
      end
    end

  end
end
