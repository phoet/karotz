$:.unshift 'lib'
require 'karotz'

def create
  Karotz::Client.create
end

Karotz::Configuration.configure do |config|
  config.install_id = ENV['KAROTZ_INSTALL_ID']
  config.api_key    = ENV['KAROTZ_API_KEY']
  config.secret     = ENV['KAROTZ_SECRET']
end

@client = create

at_exit { @client.stop }
