require 'base64'
require 'httpi'
require 'uri'
require 'httpclient'

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
      p url = "#{API}start?#{query}&signature=#{URI.encode(signed)}"
      url
    end

    def self.ears(interactive_id, params={:reset => true})
      raise "interactive_id is needed!" unless interactive_id
      HTTPI.get "#{API}ears?#{create_query({ :interactiveid => interactive_id }.merge(params))}"
    end


    def self.led(interactive_id, params={:action => :pulse, :color => "00FF00", :period => 3000, :pulse => 500})
      raise "interactive_id is needed!" unless interactive_id
      HTTPI.get "#{API}led?#{create_query({ :interactiveid => interactive_id }.merge(params))}"
    end
    
    def self.interactivemode(interactive_id, params={:action => :stop})
      HTTPI.get "#{API}interactivemode?#{create_query({ :interactiveid => interactive_id }.merge(params))}"
    end

    private()

    def self.create_query(params)
      params.sort.map { |key, value| "#{key}=#{URI.encode(value.to_s)}" }.join('&')
    end

  end
end
