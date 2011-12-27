$:.unshift 'lib'
require 'karotz'

Karotz::Configuration.configure do |config|
  config.install_id = ENV['KAROTZ_INSTALL_ID']
  config.api_key    = ENV['KAROTZ_API_KEY']
  config.secret     = ENV['KAROTZ_SECRET']
end

@client = Karotz::Client.new(Karotz::Client.start)
