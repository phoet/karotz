require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Karotz
  describe Client do

    COLORS = {
      :blue => '0000FF',
      :red => 'FF0000',
      :green => '00FF00',
      :yellow => 'FFFF00'
    }

    before(:each) do
      @install_id = ENV['KAROTZ_INSTALL_ID']
      @api_key = ENV['KAROTZ_API_KEY']
      @secret = ENV['KAROTZ_SECRET']
      # currently retrieved via
      # http://www.karotz.com/authentication/run/karotz/API_KEY
      # cause login-process does throws 502 BAD_GATEWAY
      @interactive_id = "4b434bfc-b4a0-4f69-9420-04f2b37a61ed"
    end

    it "should create a signed url" do
      Client.start_url(@install_id, @api_key, @secret, '7112317', '1324833464').should eql('http://api.karotz.com/api/karotz/start?apikey=7afdd4b7-3bc8-4469-bda2-1d8bc1e218a0&installid=1a9bf66d-6a47-4f6e-a260-d42fd70a5583&once=7112317&timestamp=1324833464&signature=hhE0T+UwSTD1aCfaE6MJXshYDHs=')
    end

    context "ears" do

      it "should wiggle the ears" do
        Client.ears(@interactive_id)
      end

      it "should make the bull" do
        params = {
          :left => 0,
          :right => 0,
          :relative => false
        }
        Client.ears(@interactive_id, params)
      end

      it "should look sad" do
        params = {
          :left => 90,
          :right => 90,
          :relative => false
        }
        Client.ears(@interactive_id, params)
      end

      it "should reset the ears" do
        params = {
          :reset => true
        }
        Client.ears(@interactive_id, params)
      end
    end

    context "led" do
      it "should pulse" do
        Client.led(@interactive_id)
      end
    end

    context "interactivemode" do
      it "should stop the mode" do
        Client.interactivemode(@interactive_id)
      end
    end

  end
end
