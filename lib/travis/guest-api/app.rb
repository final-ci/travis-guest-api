require 'travis/support'
require 'travis/support/metrics'
require 'sinatra/base'
require 'rack/parser'
require 'multi_json'

require 'travis/guest-api/app/middleware/rewrite'
require 'travis/guest-api/app/middleware/logging'
require 'travis/guest-api/app/endpoint/steps'
require 'travis/guest-api/app/endpoint/logs'
require 'travis/guest-api/app/endpoint/started'
require 'travis/guest-api/app/endpoint/finished'
require 'travis/guest-api/app/endpoint/home'
require 'travis/guest-api/app/endpoint/uptime'
require 'travis/guest-api/app/endpoint/networks'
require 'travis/guest-api/app/endpoint/attachments'
require 'travis/guest-api/app/endpoint/restarts'
require 'travis/guest-api/app/endpoint/snapshots'

#require 'travis/worker'
#require 'travis/worker/reporter'
#require 'travis/worker/utils/serialization'

module Travis::GuestApi

  class App

    attr_reader :app

    def initialize(job_id, reporter = nil, &block)
      @job_id = job_id
      @reporter = reporter
      @msg_handler = block

      @app = Rack::Builder.app do
        use Rack::CommonLogger
        use Rack::Parser, :parsers => { 'application/json' => Proc.new { |body| ::MultiJson.decode body } }
        use Travis::GuestApi::App::Middleware::Logging
        use Travis::GuestApi::App::Middleware::Rewrite
        map '/api/v2' do
          use Travis::GuestApi::App::Endpoint::Logs
          use Travis::GuestApi::App::Endpoint::Steps
          use Travis::GuestApi::App::Endpoint::Started
          use Travis::GuestApi::App::Endpoint::Finished
          use Travis::GuestApi::App::Endpoint::Uptime
          use Travis::GuestApi::App::Endpoint::Networks
          use Travis::GuestApi::App::Endpoint::Attachments
          use Travis::GuestApi::App::Endpoint::Restarts
          use Travis::GuestApi::App::Endpoint::Snapshots
          run Travis::GuestApi::App::Endpoint::Home.new
        end
      end
    end

    def call(env)
      env['job_id'] = @job_id
      env['reporter'] = @reporter
      env['msg_handler'] = @msg_handler
      app.call(env)
    end
  end

end
