namespace :karotz do
  namespace :build do
    desc "build failed trigger"
    task :failed => :setup do
      Karotz::Client.session do |karotz|
        karotz.light :color => Karotz::Color::RED
        karotz.speak :text => "build failed"
        sleep(3) # kill session some time after talking
      end
    end

    desc "build normal trigger"
    task :normal => :setup do
      Karotz::Client.session do |karotz|
        karotz.light :color => Karotz::Color::GREEN
        karotz.speak :text => "build normal"
        sleep(3) # kill session some time after talking
      end
    end

    task :setup do
      Karotz::Configuration.configure do |config|
        config.install_id = ENV['KAROTZ_INSTALL_ID']
        config.api_key    = ENV['KAROTZ_API_KEY']
        config.secret     = ENV['KAROTZ_SECRET']
        config.proxy      = ENV['KAROTZ_PROXY']
      end
    end
  end
end
