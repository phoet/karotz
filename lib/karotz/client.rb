require 'cgi'
require 'base64'
require 'httpi'
require 'httpclient'
require 'crack'

module Karotz
  class Client

    def initialize(interactive_id)
      @interactive_id = interactive_id
    end

    def method_missing(meth, *args, &blk)
      if self.class.respond_to? meth
        args.unshift @interactive_id
        self.class.send meth, *args, &blk
      else
        super
      end
    end

    def respond_to?(meth)
      self.class.respond_to?(meth) || super
    end

    API = "http://api.karotz.com/api/karotz/"
    DIGEST  = OpenSSL::Digest::Digest.new('sha1')

    #==========EARS=================


    def self.ears(interactive_id, params={:reset => true})
      request :ears, interactive_id, params
    end

    #============LED================

    def self.led(interactive_id, params={:action => :pulse, :color => Color::BLUE, :period => 3000, :pulse => 500})
      request :led, interactive_id, params
    end

    def self.fade(interactive_id, params={:color => Color::BLUE, :period => 3000})
      request :led, interactive_id, {:action => :fade}.merge(params)
    end

    def self.light(interactive_id, params={:color => Color::BLUE})
      request :led, interactive_id, {:action => :light}.merge(params)
    end

    #============LIFE_CYCLE=========

    def self.start
      url = start_url(Configuration.install_id, Configuration.api_key, Configuration.secret)
      response = HTTPI.get(url)
      answer = Crack::XML.parse(response.body)
      raise "could not retrieve interactive_id" if answer["VoosMsg"].nil? || answer["VoosMsg"]["interactiveMode"].nil? || answer["VoosMsg"]["interactiveMode"]["interactiveId"].nil?
      answer["VoosMsg"]["interactiveMode"]["interactiveId"]
    end

    def self.stop(interactive_id, params={:action => :stop})
      request :interactivemode, interactive_id, params
    end

    def self.session
      interactive_id = start
      yield(new(interactive_id))
    ensure
      stop(interactive_id)
    end

    #===========HELPERS================

    def self.start_url(install_id, api_key, secret, once=rand(99999999999999), timestamp=Time.now.to_i)
      params = {
        'installid'   => install_id,
        'apikey'      => api_key,
        'once'        => once,
        'timestamp'   => timestamp,
      }
      query   = create_query(params)
      hmac    = OpenSSL::HMAC.digest(DIGEST, secret, query)
      encoded = Base64.encode64(hmac).chomp
      signed  = CGI.escape(encoded)
      "#{API}start?#{query}&signature=#{signed}"
    end

    private()

    def self.request(endpoint, interactive_id, params={})
      raise "interactive_id is needed!" unless interactive_id
      raise "endpoint is needed!" unless endpoint
      url = "#{API}#{endpoint}?#{create_query({ :interactiveid => interactive_id }.merge(params))}"
      response = HTTPI.get(url)
      answer = Crack::XML.parse(response.body)
      raise "bad response from server" unless answer["VoosMsg"]["response"]["code"] == "OK"
    end

    def self.create_query(params)
      params.map { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.sort.join('&')
    end

  end
end

if __FILE__ == $PROGRAM_NAME
  require File.dirname(__FILE__) + "/configuration"
  Karotz::Configuration.configure do |config|
    config.install_id = ENV['KAROTZ_INSTALL_ID']
    config.api_key    = ENV['KAROTZ_API_KEY']
    config.secret     = ENV['KAROTZ_SECRET']
  end

  interactive_id = Karotz::Client.start
  Karotz::Client.stop(interactive_id)
end
