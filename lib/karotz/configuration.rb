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

    class << self
      def validate_credentials!
        raise "you have to configure Karotz: 'configure :install_id => 'your-install-id', :api_key => 'your-api-key', :secret => 'your-secret'" if blank?(:api_key) || blank?(:secret) || blank?(:install_id)
      end

      def blank?(key)
        val = self.send key
        val.nil? || val.empty?
      end
    end
  end
end
