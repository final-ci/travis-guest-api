require 'travis/guest-api/config'

module Travis
  module GuestApi

    class << self
      def config
        @config ||= Config.new
      end
    end

  end
end
