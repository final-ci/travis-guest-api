require 'travis/config'

module Travis::GuestApi
  class Config < Travis::Config

    define  attachment_service_URL:  'http://foo.bar/baz',
            cache: { expire_hours: 24 },
            redis: { url: nil }

  end
end
