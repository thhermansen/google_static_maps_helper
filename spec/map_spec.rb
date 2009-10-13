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

    it "should be able to read initialized key option from object" do
      GoogleStaticMapsHelper::Map.new(@@require_options).options[:key].should == @@require_options[:key]
    end

    @@require_options.each_key do |key|
      it "should provide a short cut method to read the option #{key}" do
        GoogleStaticMapsHelper::Map.new(@@require_options).send(key).should == @@require_options[key]
      end
    end
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





  before :each do
    @key = 'MY_GOOGLE_KEY'
    @size = '400x600'
    @sensor = true
    @map = GoogleStaticMapsHelper::Map.new(:key => @key, :size => @size, :sensor => @sensor)
    
    @marker1  = GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2)
    @marker11 = GoogleStaticMapsHelper::Marker.new(:lng => 3, :lat => 4)

    @marker2  = GoogleStaticMapsHelper::Marker.new(:lng => 5, :lat => 6, :color => 'green')
    @marker22 = GoogleStaticMapsHelper::Marker.new(:lng => 7, :lat => 8, :color => 'green')
  end

  describe "URL" do
    it "should raise exception if called with no markers nor center and zoom" do
      lambda{@map.url}.should raise_error(GoogleStaticMapsHelper::BuildDataMissing)
    end

    it "should not raise exception if markers are in map" do
      @map << @marker1
      lambda{@map.url}.should_not raise_error(GoogleStaticMapsHelper::BuildDataMissing)
    end

    it "should not raise exception if center and zoom is set" do
      @map.options.merge!(:zoom => 1, :center => '1,1')
      lambda{@map.url}.should_not raise_error(GoogleStaticMapsHelper::BuildDataMissing)
    end
  end
end
