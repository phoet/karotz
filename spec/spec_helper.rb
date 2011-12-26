$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')

require "rspec"
require "pry"
require "vcr"
require "karotz"

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :webmock
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.around(:each, :vcr => true) do |example|
    name = example.metadata[:full_description].downcase.gsub(/\W+/, "_").split("_", 2).join("/")
    VCR.use_cassette(name, :record => :new_episodes, :match_requests_on => [:host, :path]) do
      example.call
    end
  end

  config.before :each do
    HTTPI.log = false

    @install_id = ENV['KAROTZ_INSTALL_ID']
    @api_key = ENV['KAROTZ_API_KEY']
    @secret = ENV['KAROTZ_SECRET']
    # currently retrieved via
    # http://www.karotz.com/authentication/run/karotz/API_KEY
    # cause login-process does throws 502 BAD_GATEWAY
    @interactive_id = "117c09d2-02b9-4b38-b64b-9b821ac7c91c"

    Karotz::Configuration.reset
  end
end

# setup for travis-ci
ENV['KAROTZ_INSTALL_ID'] ||= 'KAROTZ_INSTALL_ID'
ENV['KAROTZ_API_KEY']    ||= 'KAROTZ_API_KEY'
ENV['KAROTZ_SECRET']     ||= 'KAROTZ_SECRET'
