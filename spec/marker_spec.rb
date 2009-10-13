require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Marker do
  before :each do
    @location_hash = {:lat => 10, :lng => 20}
    @location_object = mock(:location, @location_hash)
  end
  
  describe "initialize" do
    it "should raise ArgumentError if no arguments are given" do
      lambda {GoogleStaticMapsHelper::Marker.new}.should raise_error(ArgumentError)
    end

    describe "get location as object" do
      [:lat, :lng].each do |location_property|
        it "should extract #{location_property} from first argument if that is object" do
          marker = GoogleStaticMapsHelper::Marker.new(@location_object)
          marker.send(location_property).should == @location_object.send(location_property)
        end
      end

      it "should raise NoLngMethod if object doesn't respond to lng" do
        lambda {GoogleStaticMapsHelper::Marker.new(mock(:location, :lat => 10))}.should raise_error(GoogleStaticMapsHelper::Marker::NoLngMethod)
      end

      it "should raise NoLatMethod if object doesn't respond to lat" do
        lambda {GoogleStaticMapsHelper::Marker.new(mock(:location, :lng => 20))}.should raise_error(GoogleStaticMapsHelper::Marker::NoLatMethod)
      end
    end

    describe "get location from hash" do
      [:lat, :lng].each do |location_property|
        it "should extract #{location_property} from hash" do
          marker = GoogleStaticMapsHelper::Marker.new(@location_hash)
          marker.send(location_property).should == @location_object.send(location_property)
        end
      end
      
      it "should raise NoLngKey if hash doesn't have key lng" do
        lambda {GoogleStaticMapsHelper::Marker.new(:lat => 10)}.should raise_error(GoogleStaticMapsHelper::Marker::NoLngKey)
      end

      it "should raise NoLatKey if hash doesn't have key lat" do
        lambda {GoogleStaticMapsHelper::Marker.new(:lng => 20)}.should raise_error(GoogleStaticMapsHelper::Marker::NoLatKey)
      end
    end


    describe "options" do
      describe "defaults" do
        it "should have a predefined color which location should use" do
          marker = GoogleStaticMapsHelper::Marker.new(@location_object)
          marker.options[:color].should == 'red'
        end

        it "should have a predefined size" do
          marker = GoogleStaticMapsHelper::Marker.new(@location_object)
          marker.options[:size].should == 'mid'
        end

        it "should have a predefined label which should be nil" do
          marker = GoogleStaticMapsHelper::Marker.new(@location_object)
          marker.options[:label].should be_nil
        end
      end

      describe "override options as second parameters, location given as object as first param" do
        {:color => 'blue', :size => 'small', :label => 'A'}.each_pair do |key, value|
          it "should be possible to override #{key} to #{value}" do
            marker = GoogleStaticMapsHelper::Marker.new(@location_object, {key => value})
            marker.options[key].should == value
          end
        end
      end

      describe "override options as first parameter, location mixed into the same hash" do
        {:color => 'blue', :size => 'small', :label => 'A'}.each_pair do |key, value|
          it "should be possible to override #{key} to #{value}" do
            marker = GoogleStaticMapsHelper::Marker.new(@location_hash.merge({key => value}))
            marker.options[key].should == value
          end
        end
      end
    end
  end
  

  describe "Short cut methods" do
    [:color, :size, :label].each do |attribute|
      before :each do 
        @options = {:lat => 1, :lng => 2, :color => 'Green', :label => 'A', :size => 'small'}
        @marker = GoogleStaticMapsHelper::Marker.new(@options)
      end

      it "should return the option #{attribute} as an attribute" do
        @marker.send(attribute).should == @options[attribute]
      end
    end
  end
end
