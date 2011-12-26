require 'uri'
require 'base64'
require 'httpi'
require 'httpclient'
require 'crack'

module Karotz
  class Client

    API = "http://api.karotz.com/api/karotz/"
    DIGEST  = OpenSSL::Digest::Digest.new('sha1')

    def self.start_url(installid, apikey, secret, once=(rand(9999999) + 1000000), timestamp=Time.now.to_i)
      params = {
        'installid' => installid,
        'apikey' => apikey,
        'once' => once.to_s,
        'timestamp' => timestamp.to_s,
      }
      query = create_query(params)
      hmac = OpenSSL::HMAC.digest(DIGEST, secret, query)
      signed = Base64.encode64(hmac).strip
      "#{API}start?#{query}&signature=#{URI.encode(signed)}"
    end

    def self.ears(interactive_id, params={:reset => true})
      request :ears, interactive_id, params
    end

    #============LED================

    def self.led(interactive_id, params={:action => :pulse, :color => "00FF00", :period => 3000, :pulse => 500})
      request :led, interactive_id, params
    end

    def self.fade(interactive_id, params={:color => '77FF44', :period => 3000})
      request :led, interactive_id, {:action => :fade}.merge(params)
    end

    def self.light(interactive_id, params={:color => '77FF44'})
      request :led, interactive_id, {:action => :light}.merge(params)
    end

    #============LIFE_CYCLE=========

    def self.interactivemode(interactive_id, params={:action => :stop})
      request :interactivemode, interactive_id, params
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
      params.map { |key, value| "#{key}=#{URI.encode(value.to_s)}" }.sort.join('&')
    end

  end
end
