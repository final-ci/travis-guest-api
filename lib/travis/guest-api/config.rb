require 'travis/config'
require 'travis/support'

module Travis
  module Logs
    class Config < Travis::Config
      #define  amqp:          { username: 'travisci_worker', password: 'travisci_worker_password', vhost: 'travisci.development', prefetch: 1 },
      define  amqp:          { username: 'travisci_worker', password: 'travisci_worker_password', vhost: 'travisci.development', host: 'localhost', prefetch: 1 },
              #logs_database: { adapter: 'postgresql', database: "travis_results_#{Travis.env}", encoding: 'unicode', min_messages: 'warning' },
              metrics:       { reporter: 'librato' },
              ssl:           { },

      default _access: [:key]

      def env
        Travis.env
      end
    end
  end
end
