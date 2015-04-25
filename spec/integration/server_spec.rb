require 'spec_helper'
require 'faraday'

require 'travis/guest-api/server'
require 'rack/test'

module Travis::GuestApi
  describe Server do
    include Rack::Test::Methods

    let(:callback) { ->(x) { } }

    it "starts server" do
      s = Travis::GuestApi::Server.new(1, nil, nil, &callback).start
      sleep 0.5
      response = Faraday.get "http://localhost:#{s.port}/uptime"
      s.stop
      expect(response.status).to eq(204)
    end

    it "should start and stop servers" do

      # there should be some stopping thred in the progress
      sleep 3

      initial_thread_count = Thread.list.size
      s1 = Travis::GuestApi::Server.new(1, nil, nil, &callback).start
      s2 = Travis::GuestApi::Server.new(1, nil, nil, &callback).start
      s3 = Travis::GuestApi::Server.new(1, nil, nil, &callback).start
      s3.stop
      s1.stop
      sleep 0.5
      s2.stop
      sleep 3.5
      expect(Thread.list.size).to eq(initial_thread_count)
    end


  end
end
