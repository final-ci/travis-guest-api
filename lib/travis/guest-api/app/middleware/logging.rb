require 'travis/guest-api/app'

class Travis::GuestApi::App::Middleware
  # Makes sure we use Travis.logger everywhere.
  class Logging <  Travis::GuestApi::App::Base
    set(:setup) { ActiveRecord::Base.logger = Travis.logger }

    before do
      env['rack.logger'] = Travis.logger
      env['rack.errors'] = Travis.logger.instance_variable_get(:@logdev).dev rescue nil
    end
  end
end
