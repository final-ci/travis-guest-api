require 'travis/guest-api/config'
require 'travis/guest-api/cache'

module Travis
  module GuestApi
    class << self
      def config
        @config ||= defined?(Travis::Worker) ? Travis::Worker.config : Config.new
      end

      def cache
        @cache ||= Travis::GuestAPI::Cache.new
      end
    end
  end
end
