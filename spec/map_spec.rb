require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Map do
  @@require_options = {
    :size => '800x600',
    :key => 'MY_GOOGLE_KEY',
    :sensor => false
  }

  describe "initialize" do
    before do
      @@require_options.each_key {|k| GoogleStaticMapsHelper.send("#{k}=", nil)}
    end

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
      GoogleStaticMapsHelper::Map.new(@@require_options).key.should == @@require_options[:key]
    end
    
    @@require_options.each_key do |key|
      it "should use #{key} from GoogleStaticMapsHelper class attribute if set" do
        option_with_missing_option = @@require_options.dup
        GoogleStaticMapsHelper.send("#{key}=", option_with_missing_option.delete(key))
        map = GoogleStaticMapsHelper::Map.new(option_with_missing_option)
        map.send(key).should == GoogleStaticMapsHelper.send(key)
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

    it "should be able to push map << marker << marker" do
      @map << @marker << GoogleStaticMapsHelper::Marker.new(:lat => 3, :lng => 5)
      @map.length.should == 2
    end
  end

  
  describe "Grouped markers" do
    before :each do
      @marker1  = GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2)
      @marker11 = GoogleStaticMapsHelper::Marker.new(:lng => 3, :lat => 4)

      @marker2  = GoogleStaticMapsHelper::Marker.new(:lng => 5, :lat => 6, :color => 'green')
      @marker22 = GoogleStaticMapsHelper::Marker.new(:lng => 7, :lat => 8, :color => 'green')
      @map = GoogleStaticMapsHelper::Map.new(:key => @key, :size => @size, :sensor => @sensor)
    end

    it "should return options_to_url_params as key, array with markers as value" do
      @map << @marker1
      @map << @marker11
      @map << @marker2
      @map << @marker22
      @map.grouped_markers.should == {
        @marker1.options_to_url_params => [@marker1, @marker11],
        @marker2.options_to_url_params => [@marker2, @marker22]
      }
    end
  end


  describe "size" do
    before do
      @map = GoogleStaticMapsHelper::Map.new(@@require_options)
      @map.size = '300x400'
    end

    it "should return map's width" do
      @map.width.should == 300
    end

    it "should return map's height" do
      @map.height.should == 400
    end

    it "should be able to set width with width :-)" do
      @map.width = '300'
      @map.width.should == 300
    end

    it "should be able to set height" do
      @map.height = '300'
      @map.height.should == 300
    end

    it "should be able to set width and height via size as an array" do
      @map.size = [200, 300]
      @map.size.should == '200x300'
    end

    it "should be able to set width and height via size as a hash" do
      @map.size = {:width => 100, :height => 500}
      @map.size.should == '100x500'
    end

    it "should be possible to only set height via size as a hash" do
      @map.size = {:height => 500}
      @map.size.should == '300x500'
    end

    it "should be possible to only set width via size as a hash" do
      @map.size = {:width => 500}
      @map.size.should == '500x400'
    end
  end

  describe "URL" do
    before :each do
      @key = 'MY_GOOGLE_KEY'
      @size = '400x600'
      @sensor = false
      @map = GoogleStaticMapsHelper::Map.new(:key => @key, :size => @size, :sensor => @sensor)
      
      @marker1  = GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2)
      @marker11 = GoogleStaticMapsHelper::Marker.new(:lng => 3, :lat => 4)

      @marker2  = GoogleStaticMapsHelper::Marker.new(:lng => 5, :lat => 6, :color => 'green')
      @marker22 = GoogleStaticMapsHelper::Marker.new(:lng => 7, :lat => 8, :color => 'green')
    end

    describe "valid state to run URL" do
      it "should raise exception if called with no markers nor center and zoom" do
        lambda{@map.url}.should raise_error(GoogleStaticMapsHelper::BuildDataMissing)
      end

      it "should not raise exception if markers are in map" do
        @map << @marker1
        lambda{@map.url}.should_not raise_error(GoogleStaticMapsHelper::BuildDataMissing)
      end

      it "should not raise exception if center and zoom is set" do
        @map.zoom = 1
        @map.center = '1,1'
        lambda{@map.url}.should_not raise_error(GoogleStaticMapsHelper::BuildDataMissing)
      end
    end

    describe "required parameters" do
      before :each do
        @map.zoom = 1
        @map.center = '1,1'
      end

      it "should start with the URL to the API" do
        @map.url.should include(GoogleStaticMapsHelper::API_URL)
      end

      it "should include the key" do
        @map.url.should include("key=#{@key}")
      end
      
      it "should include the size" do
        @map.url.should include("size=#{@size}")
      end
      
      it "should include the sensor" do
        @map.url.should include("sensor=#{@sensor}")
      end
    end

    describe "with no markers in map" do
      before :each do
        @map.zoom = 1
        @map.center = '1,1'
      end
      
      it "should contain center=2,3" do
        @map.url.should include("center=1,1")
      end
      
      it "should contain zoom=1" do
        @map.url.should include("zoom=1")
      end

      it "should not include markers param" do
        @map.url.should_not include("markers=")
      end
    end


    describe "with markers, no one grouped" do
      before :each do
        @map << @marker1
        @map << @marker2
      end
      
      [
        ['key', 'MY_GOOGLE_KEY'],
        ['sensor', 'false'],
        ['size', '400x600'],
        ['markers', 'color:green|size:mid|6,5'],
        ['markers', 'color:red|size:mid|2,1']
      ].each do |pair|
        key, value = pair
        it "should have key: #{key} and value: #{value}" do
          @map.url.should include("#{key}=#{value}")
        end
      end
    end

    describe "with markers grouped together" do
      before :each do
        @map.sensor = true
        @map << @marker1
        @map << @marker11
        @map << @marker2
        @map << @marker22
      end

      [
        ['key', 'MY_GOOGLE_KEY'],
        ['sensor', 'true'],
        ['size', '400x600'],
        ['markers', 'color:green|size:mid|6,5|8,7'],
        ['markers', 'color:red|size:mid|2,1|4,3']
      ].each do |pair|
        key, value = pair
        it "should have key: #{key} and value: #{value}" do
          @map.url.should include("#{key}=#{value}")
        end
      end
    end
  end
  
  it "should provide a helper method named marker which will create a new marker and add it to the map" do
    map = GoogleStaticMapsHelper::Map.new(@@require_options)
    map.marker(:lat => 1, :lng => 2)
    map.length.should eql(1)
  end
end
