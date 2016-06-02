require 'travis/guest-api/config'
require 'travis/guest-api/cache'

module Travis
  module GuestApi
    class << self
      def config
        @config ||= defined?(Travis::Worker) ? Travis::Worker.config : Config.load
      end

      def cache
        expire = Travis.config.cache.expire_hours.to_i.hours
        fail 'Please specify valid redis url' if Travis.config.redis.url.nil?
        @cache ||= Travis::GuestAPI::Cache.new expire, Travis.config.redis
      end
    end
  end

  class << self
    def config
      Travis::GuestApi.config
    end
  end
end
