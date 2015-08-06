require 'spec_helper'
require 'rack/test'
require 'travis/guest-api/app/middleware/rewrite'

describe Travis::GuestApi::App::Middleware::Rewrite do

  include Rack::Test::Methods

  def app
    Travis::GuestApi::App.new(job_id, reporter, &callback)
  end

  let(:job_id) { @job_id }
  let(:reporter) { double(:reporter) }
  let(:callback) { ->(x) { } }

  it 'rewrites job_id to environment' do
    job_id = 42
    get("/jobs/#{job_id}/uptime")
    expect(last_request.env['job_id']).to eq(job_id.to_s)
  end

  it 'responds with 422 on job_id mismatch' do
    @job_id = 123
    response = get("/jobs/456/uptime")
    expect(response.status).to eq(422)
  end
end
