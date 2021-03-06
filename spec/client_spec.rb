require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Karotz
  describe Client do
    it "should create a signed url" do
      args = ['INSTALL_ID', 'API_KEY', 'SECRET', '7112317', '1324833464']
      url  = "http://api.karotz.com/api/karotz/start?apikey=API_KEY&installid=INSTALL_ID&once=7112317&timestamp=1324833464&signature=Vb%2ByZK3eNlXGh%2B9DfnwIqQ%2BZIAE%3D"
      Client.start_url(*args).should eql(url)
    end

    context "ears" do
      it "should wiggle the ears", :vcr => true do
        Client.ears(@interactive_id)
      end

      it "should make the bull", :vcr => true do
        params = {
          :left => 0,
          :right => 0,
          :relative => false
        }
        Client.ears(@interactive_id, params)
      end

      it "should look sad", :vcr => true do
        params = {
          :left => 9,
          :right => 9,
          :relative => false
        }
        Client.ears(@interactive_id, params)
      end

      it "should reset the ears", :vcr => true do
        params = {
          :reset => true
        }
        Client.ears(@interactive_id, params)
      end
    end

    context "led" do
      it "should pulse", :vcr => true do
        Client.pulse(@interactive_id)
      end

      it "should fade", :vcr => true do
        Client.fade(@interactive_id)
      end

      it "should light", :vcr => true do
        Client.light(@interactive_id)
      end
    end

    context "text to speach (tts)" do
      it "should say something", :vcr => true do
        Client.speak(@interactive_id)
      end
    end

    context "automatic speach recognition (asr)" do
      it "should listen to voice", :vcr => true do
        Client.listen(@interactive_id)
      end
    end

    context "multimedia" do
      it "should play mp3", :vcr => true do
        Client.play(@interactive_id)
      end
    end

    context "webcam" do
      it "should take a picture and upload it", :vcr => true do
        Client.snap(@interactive_id)
      end
    end

    context "config" do
      it "should retrieve the config", :vcr => true do
        Client.config(@interactive_id).should eql(
          {
            "config" => {
              "interruptible"=>"false",
              "awake"=>"false",
              "name"=>"config",
              "uuid"=>"SOME_UUID",
              "params"=>[
                {"key"=>"awake", "value"=>"false"},
                {"key"=>"interruptible", "value"=>"false"},
                {"key"=>"permanentTriggerActivator", "value"=>"false"},
                {"key"=>"scheduledDateTriggerActivator", "value"=>"false"},
                {"key"=>"scheduledTriggerActivator", "value"=>"false"}
              ]
            }
          }
        )
      end
    end

    context "lifecycle" do
      before(:each) do
        Configuration.configure do |config|
          config.install_id = ENV['KAROTZ_INSTALL_ID']
          config.api_key    = ENV['KAROTZ_API_KEY']
          config.secret     = ENV['KAROTZ_SECRET']
        end
      end

      it "should create a client with a interactive_id", :vcr => true do
        Client.create.tap do |it|
          it.interactive_id.should_not be_nil
        end
      end

      it "should start and stop the interactiveMode", :vcr => true do
        interactive_id = Client.start
        interactive_id.should_not be_empty
        Client.stop(interactive_id)
      end

      it "should do something in a block", :vcr => true do
        Client.session do |karotz|
          karotz.ears
        end
      end
    end
  end
end
