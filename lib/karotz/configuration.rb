require 'confiture'
require 'logger'
require 'openssl'

module Karotz
  class Configuration
    include Confiture::Configuration
    confiture_allowed_keys(:install_id, :api_key, :secret, :endpoint, :proxy, :logger, :digest)
    confiture_defaults({
      :secret     => '',
      :api_key    => '',
      :install_id => '',
      :proxy      => nil,
      :logger     => Logger.new(STDERR),
      :endpoint   => "http://api.karotz.com/api/karotz/",
      :digest     => OpenSSL::Digest::Digest.new('sha1'),
    })
  end
end
