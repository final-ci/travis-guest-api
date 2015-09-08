require 'spec_helper'
require 'travis/guest-api'

require 'ostruct'
require 'travis/guest-api/app'
require 'rack/test'
require 'rspec'

module Travis::GuestApi
  describe App do
    include Rack::Test::Methods

    TEST_FILE_PATH =  File.dirname(__FILE__) + "/../../../README.md"

    def app
      Travis::GuestApi::App.new(1, reporter, &callback)
    end

    let(:reporter) { double(:reporter) }
    let(:callback) { ->(x) { } }

    describe 'POST /attachments' do

      before :each do
        @test_file = Rack::Test::UploadedFile.new(TEST_FILE_PATH)
      end

      it 'returns 422 when no file uploaded' do
        post "/api/v2/attachments",
          localTime: '15:42 8/13/2015',
          indent: 666
        expect(last_response.status).to eq(422)
      end

      it 'redirects to attachment service' do
        post "/api/v2/attachments",
          local_time: '15:42 8/13/2015',
          indent: 666,
          file: @test_file,
          job_id: 1
        expect(last_request.env["CONTENT_TYPE"]).to include("multipart/form-data;")
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq Travis::GuestApi.config.attachment_service_URL
      end

    end

  end
end
