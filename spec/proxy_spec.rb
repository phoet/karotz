require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'webrick'
require 'webrick/httpproxy'
require 'thread' # for ::Mutex used in VCR middleware

module WEBrick
  class VCRProxyServer < HTTPProxyServer
    def initialize(*)
      super
      @mutex = Mutex.new
      trap('INT') { shutdown }
    end

    def service(*args)
      @mutex.synchronize do
        VCR.use_cassette('proxied') do
          super(*args) # XXX: for some reason super (with no args) does not work
        end
      end
    end
  end
end

module Karotz
  describe "proxy" do
    before :all do
      @pid = fork do
        STDERR.reopen('/dev/null', 'a')
        WEBrick::VCRProxyServer.new(:Port => 9000).start
      end

      begin
        TCPSocket.open('localhost', 9000).close
      rescue Errno::ECONNREFUSED
        retry
      end
    end

    before(:each) do
      Configuration.configure do |config|
        config.install_id = ENV['KAROTZ_INSTALL_ID']
        config.api_key    = ENV['KAROTZ_API_KEY']
        config.secret     = ENV['KAROTZ_SECRET']
        config.proxy      = 'http://localhost:9000'
      end
    end

    it "should work with a proxy", :vcr => true do
      Client.create.tap do |it|
        it.interactive_id.should_not be_nil
      end
    end
  end
end
