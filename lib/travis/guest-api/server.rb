require 'rack'
require 'rack/handler/puma'

require 'travis/guest-api/app'


#require 'celluloid'

module Travis::GuestApi
  class Server

    attr_reader :job_id, :server_thread, :api, :reporter

    def initialize(job_id, reporter = nil, server_options = nil, &block)
      @server_options = server_options || {
        Host: 'localhost',
        Threads: '1:1'
      }
      @reporter = reporter
      @job_id = job_id
      @block = block
    end

    def start
      @server_options[:Port] ||= free_port

      @server_thread = Thread.new do
        api = Travis::GuestApi::App.new(job_id, reporter, &@block)


        Rack::Handler::Puma.run(api, @server_options) { |server|
          Thread.current[:server] = server
        }
      end
      self
    end

    def stop
      Thread.new do
        # in case that stop is called immediately after start
        # e.g. server_thread should not be assigned yet
        sleep 1
        server_thread[:server].stop if server_thread[:server]
        sleep 1
      end
    end

    def port
      @server_options[:Port]
    end

    private

      def free_port
        #NOTE: This implementatin needs to be thread safe
        # in a way that don't repeat free (closed) port imedialtelly.
        # ...this linux does.
        s = Socket.new(:INET, :STREAM, 0)
        s.bind(Addrinfo.tcp("127.0.0.1", 0))
        port = s.local_address.ip_port
        s.close
        port
      end
  end
end
