require 'spec_helper'
require 'rack/test'
require 'travis/guest-api/app/middleware/rewrite'

describe Travis::GuestApi::App::Middleware::Rewrite do

  include Rack::Test::Methods

  def app
    Travis::GuestApi::App.new(job_id, reporter, &callback)
  end

  let(:job_id) { 42 }
  let(:reporter) { double(:reporter) }
  let(:callback) { ->(x) { } }

  context "server is run without job_id" do
    let(:job_id) { nil }
    it 'rewrites job_id to environment' do
      job_id_URL_param = 42
      get "/api/v1/jobs/#{job_id_URL_param}/uptime"
      expect(last_request.env['job_id']).to eq(job_id_URL_param)
      expect(last_response.status).to eq 204
    end
  end

  context "server is run with job_id 42" do
    let(:job_id) { 42 }
    it 'responds with 422 on job_id mismatch' do
      response = get "/api/v1/jobs/666/uptime"
      expect(response.status).to eq(422)
    end
  end

  describe '/machines/logs/message' do
    let!(:job_id) { 42 }
    it 'rewrites logs route' do
      expected_message = 'test message'
      expect(reporter).to receive(:send_log).with(job_id, expected_message)
      response = post "/api/v1/machines/logs/message",
        { messageText: expected_message },
        'x-MachineId' => job_id
      expect(last_request.form_data?).to be true
      expect(response.status).to eq(200)
    end

    it 'responds with 422 if MachineId not specified' do
      response = post "/api/v1/machines/logs/message", messageText: "foo"
      expect(response.status).to eq(422)
    end
  end

  describe '/machines/networks' do
    it 'rewrites networks route' do
      response = post "/api/v1/machines/networks"
      expect(response.status).to eq(501)
    end
  end

end
