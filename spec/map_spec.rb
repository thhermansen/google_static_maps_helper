require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Map do
  @@require_options = {
    :size => '800x600',
    :key => 'MY_GOOGLE_KEY',
    :sensor => false
  }


  describe "initialize" do
    @@require_options.each_key do |key|
      it "should raise OptionMissing if #{key} is not given" do
        option_with_missing_option = @@require_options.dup
        option_with_missing_option.delete(key)
        lambda {GoogleStaticMapsHelper::Map.new(option_with_missing_option)}.should raise_error(GoogleStaticMapsHelper::OptionMissing)
      end
    end

    it "should raise OptionNotExist if incomming option doesn't exists" do
      lambda {GoogleStaticMapsHelper::Map.new(@@require_options.merge(:invalid_option => 'error?'))}.should raise_error(GoogleStaticMapsHelper::OptionNotExist)
    end

    it "should "
  end

  describe "markers" do
    before :each do
      @marker = GoogleStaticMapsHelper::Marker.new(:lat => 1, :lng => 2)
      @map = GoogleStaticMapsHelper::Map.new(@@require_options)
    end

    it "should be empty as default" do
      @map.should be_empty
    end

    it "should be able to push markers onto map" do
      @map << @marker
    end

    it "should not be possible to push the same marker twice" do
      @map << @marker
      @map << @marker
      @map.length.should == 1
    end
  end
end
