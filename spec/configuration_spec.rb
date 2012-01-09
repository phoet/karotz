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
end
