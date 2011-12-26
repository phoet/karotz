require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Karotz
  describe Configuration do
    it "should be initialized with defaults" do
      Configuration.install_id.should be_empty
      Configuration.api_key.should be_empty
      Configuration.secret.should be_empty
      Configuration.logger.should_not be_nil
    end

    it "should configure with a hash" do
      Configuration.configure :api_key => 'some-key'
      Configuration.api_key.should eql('some-key')
    end

    it "should be initializable with a block" do
      Configuration.configure do |conf|
        conf.install_id = 'some-id'
      end
      Configuration.install_id.should eql('some-id')
    end
  end

  describe Client do
    it "should create a signed url" do
      Client.start_url(@install_id, @api_key, @secret, '7112317', '1324833464').should eql('http://api.karotz.com/api/karotz/start?apikey=7afdd4b7-3bc8-4469-bda2-1d8bc1e218a0&installid=1a9bf66d-6a47-4f6e-a260-d42fd70a5583&once=7112317&timestamp=1324833464&signature=hhE0T+UwSTD1aCfaE6MJXshYDHs=')
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
          :left => 90,
          :right => 90,
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
        Client.led(@interactive_id)
      end
    end

    context "interactivemode" do
      it "should stop the mode", :vcr => true do
        Client.interactivemode(@interactive_id)
      end
    end

  end
end
