require 'travis/guest-api/app'
require 'sinatra/base'

class Travis::GuestApi::App
  # Superclass for any endpoint and middleware.
  # Pulls in relevant helpers and extensions.
  class Base < Sinatra::Base

    error JSON::ParserError do
      status 400
      "Invalid JSON in request body"
    end

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
