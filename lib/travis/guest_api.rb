require 'travis/guest-api/config'
require 'travis/guest-api/cache'

module Travis
  module GuestApi
    class << self
      def config
        @config ||= defined?(Travis::Worker) ? Travis::Worker.config : Config.load
      end

      def cache
        @cache ||= Travis::GuestAPI::Cache.new
      end
    end
  end

  class << self
    def config
      Travis::GuestApi.config
    end
  end
end
