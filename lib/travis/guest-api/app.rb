require 'travis/support'
require 'travis/support/metrics'
require 'sinatra/base'
require 'rack/parser'

require 'travis/guest-api/app/middleware/rewrite'
require 'travis/guest-api/app/endpoints/testcases'
require 'travis/guest-api/app/endpoints/logs'
require 'travis/guest-api/app/endpoints/finished'
require 'travis/guest-api/app/endpoints/home'
require 'travis/guest-api/app/endpoints/uptime'

#require 'travis/worker'
#require 'travis/worker/reporter'
#require 'travis/worker/utils/serialization'

module Travis::GuestApi

  class App

    attr_reader :app

    def initialize(job_id, reporter = nil, &block)
      @job_id = job_id
      @reporter = reporter # || Travis::Worker::Reporter.new(
      #  'standalone-reporter',
      #  Travis::Amqp::Publisher.jobs('builds', unique_channel: true, dont_retry: true),
      #  Travis::Amqp::Publisher.jobs('logs', unique_channel: true, dont_retry: true),
      #  Travis::Amqp::Publisher.jobs('test_results', unique_channel: true, dont_retry: true)
      #)
      @msg_handler = block

      @app = Rack::Builder.app do
        use Rack::Parser, :parsers => { 'application/json' => proc { |data| JSON.parse data } }
        use Travis::GuestApi::App::Middleware::Rewrite
        map '/api/v2' do
          use Travis::GuestApi::App::Endpoints::Logs
          use Travis::GuestApi::App::Endpoints::TestCases
          use Travis::GuestApi::App::Endpoints::Finished
          use Travis::GuestApi::App::Endpoints::Uptime
          run Travis::GuestApi::App::Endpoints::Home.new
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
