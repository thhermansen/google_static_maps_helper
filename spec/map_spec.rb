# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Map do
  reguire_options = {
    :size => '600x400',
    :sensor => false
  }

  describe "initialize" do
    before do
      reguire_options.each_key {|k| GoogleStaticMapsHelper.send("#{k}=", nil)}
    end

    reguire_options.each_key do |key|
      it "should raise OptionMissing if #{key} is not given" do
        option_with_missing_option = reguire_options.dup
        option_with_missing_option.delete(key)
        lambda {GoogleStaticMapsHelper::Map.new(option_with_missing_option)}.should raise_error(GoogleStaticMapsHelper::OptionMissing)
      end
    end

    it "should raise OptionNotExist if incomming option doesn't exists" do
      lambda {GoogleStaticMapsHelper::Map.new(reguire_options.merge(:invalid_option => 'error?'))}.should raise_error(GoogleStaticMapsHelper::OptionNotExist)
    end

    it "should be able to read initialized key option from object" do
      GoogleStaticMapsHelper::Map.new(reguire_options).key.should == reguire_options[:key]
    end

    reguire_options.each_key do |key|
      it "should use #{key} from GoogleStaticMapsHelper class attribute if set" do
        option_with_missing_option = reguire_options.dup
        GoogleStaticMapsHelper.send("#{key}=", option_with_missing_option.delete(key))
        map = GoogleStaticMapsHelper::Map.new(option_with_missing_option)
        map.send(key).should == GoogleStaticMapsHelper.send(key)
      end
    end

    it "should be able to call new with no arguments if GoogleStaticMapsHelper class attributes are set" do
      reguire_options.each_pair {|key, value| GoogleStaticMapsHelper.send("#{key}=", value)}
      lambda {GoogleStaticMapsHelper::Map.new}.should_not raise_error
    end
  end

  describe "markers" do
    before :each do
      @marker = GoogleStaticMapsHelper::Marker.new(:lat => 1, :lng => 2)
      @map = GoogleStaticMapsHelper::Map.new(reguire_options)
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

    it "should return it's markers via markers" do
      @map << @marker
      @map << GoogleStaticMapsHelper::Path.new
      @map.markers.should == [@marker]
    end
  end


  describe "Grouped markers" do
    before :each do
      @marker1  = GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2)
      @marker11 = GoogleStaticMapsHelper::Marker.new(:lng => 3, :lat => 4)

      @marker2  = GoogleStaticMapsHelper::Marker.new(:lng => 5, :lat => 6, :color => 'green')
      @marker22 = GoogleStaticMapsHelper::Marker.new(:lng => 7, :lat => 8, :color => 'green')
      @map = GoogleStaticMapsHelper::Map.new(:size => @size, :sensor => @sensor)
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

  describe "paths" do
    before do
      @path = GoogleStaticMapsHelper::Path.new
      @point = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
      @point2 = GoogleStaticMapsHelper::Location.new(:lat => 3, :lng => 4)
      @path << @point << @point2

      @map = GoogleStaticMapsHelper::Map.new(reguire_options)
    end

    it "should be able to push paths on to map" do
      @map << @path
      @map.first.should == @path
    end

    it "should be able to paths via paths" do
      @marker = GoogleStaticMapsHelper::Marker.new(:lat => 1, :lng => 2)
      @map << @path
      @map << @marker
      @map.paths.should == [@path]
    end
  end


  describe "size" do
    before do
      @map = GoogleStaticMapsHelper::Map.new(reguire_options)
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

    it "should raise an error if width is above 640px as it is not supported by Google Maps" do
      lambda {@map.width = 641}.should raise_error RuntimeError
    end

    it "should raise an error if height is above 640px as it is not supported by Google Maps" do
      lambda {@map.height = 641}.should raise_error RuntimeError
    end
  end

  describe "format" do
    before do
      @map = GoogleStaticMapsHelper::Map.new(reguire_options)
    end

    %w{png png8 png32 gif jpg jpg-basedline}.each do |format|
      it "should be possible to set a format to #{format}" do
        @map.format = format
        @map.format.should == format
      end
    end

    it "should be able to set format as symbol" do
      @map.format = :jpg
      @map.format.should == 'jpg'
    end

    it "should raise an error if format is not supported" do
      lambda {@map.format = :not_supported}.should raise_error(GoogleStaticMapsHelper::UnsupportedFormat)
    end
  end

  describe "map type" do
    before do
      @map = GoogleStaticMapsHelper::Map.new(reguire_options)
    end

    %w{roadmap satellite terrain hybrid}.each do |type|
      it "should be possible to set map type to #{type}" do
        @map.maptype = type
        @map.maptype.should == type
      end
    end

    it "should be possible to set map type as a symbol" do
      @map.maptype = :satellite
      @map.maptype.should == 'satellite'
    end

    it "should raise error if map type is not supported" do
      lambda {@map.maptype = :not_supported}.should raise_error(GoogleStaticMapsHelper::UnsupportedMaptype)
    end
  end

  describe "URL" do
    before :each do
      @key =
      @size = '400x600'
      @sensor = false
      @map = GoogleStaticMapsHelper::Map.new(:size => @size, :sensor => @sensor)

      @marker1  = GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2)
      @marker11 = GoogleStaticMapsHelper::Marker.new(:lng => 3, :lat => 4)

      @marker2  = GoogleStaticMapsHelper::Marker.new(:lng => 5, :lat => 6, :color => 'green')
      @marker22 = GoogleStaticMapsHelper::Marker.new(:lng => 7, :lat => 8, :color => 'green')

      @marker3 = GoogleStaticMapsHelper::Marker.new(:lng => 9, :lat => 10, :icon => 'http://image.com/')
      @marker33 = GoogleStaticMapsHelper::Marker.new(:lng => 11, :lat => 12, :icon => 'http://image.com/')
    end

    describe "valid state to run URL" do
      it "should raise exception if called with no markers nor center and zoom" do
        lambda{@map.url}.should raise_error(GoogleStaticMapsHelper::BuildDataMissing)
      end

      it "should not raise exception if markers are in map" do
        @map << @marker1
        lambda{@map.url}.should_not raise_error
      end

      it "should not raise exception if center and zoom is set" do
        @map.zoom = 1
        @map.center = '1,1'
        lambda{@map.url}.should_not raise_error
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
        @map.key_without_warning = 'MY_GOOGLE_KEY'
        @map.url.should include("key=MY_GOOGLE_KEY")
      end

      it "should not include key if it's nil" do
        @map.key_without_warning = nil
        @map.url.should_not include("key=")
      end

      it "should include the size" do
        @map.url.should include("size=#{@size}")
      end

      it "should include the sensor" do
        @map.url.should include("sensor=#{@sensor}")
      end

      it "should not include format as default" do
        @map.url.should_not include("format=")
      end

      it "should include format if it has been set" do
        @map.format = :jpg
        @map.url.should include("format=jpg")
      end

      it "should not include map type as default" do
        @map.url.should_not include("maptype=")
      end

      it "should include map type if it has been set" do
        @map.maptype = :satellite
        @map.url.should include("maptype=satellite")
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
        @map << @marker3
      end

      [
        ['sensor', 'false'],
        ['size', '400x600'],
        ['markers', 'color:green|size:mid|6,5'],
        ['markers', 'color:red|size:mid|2,1'],
        ['markers', 'icon:http://image.com/|10,9']
      ].each do |(key, value)|
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
        @map << @marker3
        @map << @marker33
      end

      [
        ['sensor', 'true'],
        ['size', '400x600'],
        ['markers', 'color:green|size:mid|6,5|8,7'],
        ['markers', 'color:red|size:mid|2,1|4,3'],
        ['markers', 'icon:http://image.com/|10,9|12,11']
      ].each do |(key, value)|
        it "should have key: #{key} and value: #{value}" do
          @map.url.should include("#{key}=#{value}")
        end
      end
    end

    describe "paths" do
      before do
        @path = GoogleStaticMapsHelper::Path.new :encode_points => false
        @point = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
        @point2 = GoogleStaticMapsHelper::Location.new(:lat => 3, :lng => 4)
        @path << @point << @point2
      end

      it "should not include path in url if no paths are represented in the map" do
        @map.center = '1,2'
        @map.zoom = 11
        @map.url.should_not include("path=")
      end

      it "should include path in url if paths are represented in the map" do
        @map << @path
        @map.url.should include("path=")
      end

      [
        ['sensor', 'false'],
        ['size', '400x600'],
        ['path', 'weight:5|1,2|3,4'],
      ].each do |pair|
        key, value = pair
        it "should have key: #{key} and value: #{value}" do
          @path.weight = 5
          @map << @path
          @map.url.should include("#{key}=#{value}")
        end
      end
    end
  end

  it "should provide a helper method named marker which will create a new marker and add it to the map" do
    map = GoogleStaticMapsHelper::Map.new(reguire_options)
    map.marker(:lat => 1, :lng => 2)
    map.length.should eql(1)
  end
end
