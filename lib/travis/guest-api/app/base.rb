require 'travis/guest-api/app'
require 'sinatra/base'
require "sinatra/multi_route"

module Travis::GuestApi
  class App
    class Base < Sinatra::Base

      # / and /uptime does not need job_id
      before /^(?!\/$|\/uptime)/ do
        if env['job_id'] && params['job_id'] && (env['job_id'] != params['job_id'].to_i)
          halt 422, {
            error: 'Job_id specified both on startup and'\
                   'in the request but they do not match!'
          }.to_json
        end
        @job_id = env['job_id'] || params['job_id'].to_i
        halt 422, { error: 'Job ID must be specified.'} unless @job_id
      end

      after do
        content_type :json unless content_type
      end

      error JSON::ParserError do
        status 400
        "Invalid JSON in request body"
      end

      # Rack protocol
      def call(env)
        super
      rescue Sinatra::NotFound
        [404, {'Content-Type' => 'text/plain'}, ['Tell Lukas to fix this!']]
      end

      configure do
        disable  :logging
        enable   :raise_errors
        disable  :dump_errors
      end

      configure :development do
        # We want error pages in development, but only
        # when we don't have an error handler specified
        set :show_exceptions, :after_handler
        enable :dump_errors
      end

    end
  end
end
