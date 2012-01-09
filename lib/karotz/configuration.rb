require 'logger'

module Karotz
  class Configuration
    class << self

      attr_accessor :install_id, :api_key, :secret
      attr_accessor :endpoint, :proxy
      attr_accessor :logger, :digest

      def configure(options={})
        init_config
        if block_given?
          yield self
        else
          options.each do |key, value|
            send(:"#{key}=", value)
          end
        end
        self
      end

      def validate_credentials!
        raise "you have to configure Karotz: 'configure :install_id => 'your-install-id', :api_key => 'your-api-key', :secret => 'your-secret'" if blank?(:api_key) || blank?(:secret) || blank?(:install_id)
      end

      def reset
        init_config(true)
      end

      def blank?(key)
        val = self.send key
        val.nil? || val.empty?
      end

      private()

      def init_config(force=false)
        return if @init && !force
        @init       = true
        @secret     = ''
        @api_key    = ''
        @install_id = ''
        @proxy      = nil
        @logger     = Logger.new(STDERR)
        @endpoint   = "http://api.karotz.com/api/karotz/"
        @digest     = OpenSSL::Digest::Digest.new('sha1')
      end
    end
  end
end
