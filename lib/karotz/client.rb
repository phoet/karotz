require 'cgi'
require 'base64'
require 'httpi'
require 'httpclient'
require 'crack'

module Karotz
  class Client
    attr_accessor :interactive_id

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

    class << self # TODO add the rest of the API calls

      #==========EARS=================

      def ears(interactive_id, params={:reset => true})
        request :ears, interactive_id, params
      end

      def sad(interactive_id)
        ears interactive_id, :left => 9, :right => 9
      end

      #============LED================

      def led(interactive_id, params={})
        request :led, interactive_id, {:action => :pulse, :color => Color::BLUE, :period => 3000, :pulse => 500}.merge(params)
      end
      alias :pulse :led

      def fade(interactive_id, params={})
        request :led, interactive_id, {:action => :fade, :color => Color::BLUE, :period => 3000}.merge(params)
      end

      def light(interactive_id, params={})
        request :led, interactive_id, {:action => :light, :color => Color::BLUE}.merge(params)
      end

      #============TTS================

      def tts(interactive_id, params={})
        request :tts, interactive_id, {:action => :speak, :text => "test", :lang => Language::ENGLISH}.merge(params)
      end
      alias :speak :tts

      #============ASR================

      def asr(interactive_id, params={})
        request :asr, interactive_id, {:grammar => 'ruby', :lang => Language::ENGLISH}.merge(params)
      end
      alias :listen :asr

      #============MULTIMEDIA=========

      def multimedia(interactive_id, params={})
        request :multimedia, interactive_id, {:action => Karotz::Multimedia::PLAY, :url => "http://www.jimwalls.net/mp3/ATeam.mp3"}.merge(params)
      end
      alias :play :multimedia

      def nyan(interactive_id)
        multimedia interactive_id, :url => "http://api.ning.com:80/files/3zmSvhA*3jKxFJj1I5uh5dp5oCynyyMksQjwS3JWWQNlriTzDzX61KtlFnuQtx-hEmV7NdqVgofmZvh7cXOX-UVJ47m1SR4a/nyanlooped.mp3"
      end

      #============WEBCAM=========

      def webcam(interactive_id, params={})
        request :webcam, interactive_id, {:action => :photo, :url => "https://picasaweb.google.com/data/feed/api/phoet6/default/albumid/default"}.merge(params)
      end
      alias :snap :webcam
      alias :cam :webcam

      #============CONFIG=========

      def config(interactive_id)
        answer = perform_request(:config, interactive_id)
        answer["ConfigResponse"]
      end

      #============LIFE_CYCLE=========

      def start
        Configuration.validate_credentials!
        url = start_url(Configuration.install_id, Configuration.api_key, Configuration.secret)
        Configuration.logger.debug "calling karotz api with url '#{url}'"
        response = HTTPI.get(url)
        answer = Crack::XML.parse(response.body)
        Configuration.logger.debug "answer was '#{answer}'"
        raise "could not retrieve interactive_id" if answer["VoosMsg"].nil? || answer["VoosMsg"]["interactiveMode"].nil? || answer["VoosMsg"]["interactiveMode"]["interactiveId"].nil?
        answer["VoosMsg"]["interactiveMode"]["interactiveId"]
      end

      def stop(interactive_id, params={})
        request(:interactivemode, interactive_id, {:action => :stop}.merge(params))
      end
      alias :destroy :stop
      alias :disconnect :stop

      def session # TODO multimedia-api is not blocking, so we need some whay to find out when we can kill the session properly
        client = create
        yield(client)
      ensure
        stop(client.interactive_id) if client
      end

      def create
        interactive_id = start
        new(interactive_id)
      end
      alias :connect :create

      #===========HELPERS================

      def start_url(install_id, api_key, secret, once=rand(99999999999999), timestamp=Time.now.to_i)
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

      def request(endpoint, interactive_id, params={})
        answer = perform_request(endpoint, interactive_id, params)
        raise "bad response from server" if answer["VoosMsg"].nil? || answer["VoosMsg"]["response"].nil? || answer["VoosMsg"]["response"]["code"] != "OK"
      end

      def perform_request(endpoint, interactive_id, params={})
        raise "interactive_id is needed!" unless interactive_id
        raise "endpoint is needed!" unless endpoint
        url = "#{API}#{endpoint}?#{create_query({ :interactiveid => interactive_id }.merge(params))}"
        Configuration.logger.debug "calling karotz api with url '#{url}'"
        response = HTTPI.get(url)
        answer = Crack::XML.parse(response.body)
        Configuration.logger.debug "answer was '#{answer}'"
        answer
      end

      def create_query(params)
        params.map { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.sort.join('&')
      end
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
