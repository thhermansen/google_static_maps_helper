require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Location do
  before :each do
    @location_hash = {:lat => 10, :lng => 20}
    @location_object = mock(:location, @location_hash)
  end
  
  describe "initialize" do
    it "should raise ArgumentError if no arguments are given" do
      lambda {GoogleStaticMapsHelper::Location.new}.should raise_error(ArgumentError)
    end

    describe "get location as object" do
      [:lat, :lng].each do |location_property|
        it "should extract #{location_property} from first argument if that is object" do
          marker = GoogleStaticMapsHelper::Location.new(@location_object)
          marker.send(location_property).should == @location_object.send(location_property)
        end
      end

      it "should raise NoLngMethod if object doesn't respond to lng" do
        lambda {GoogleStaticMapsHelper::Location.new(mock(:location, :lat => 10))}.should raise_error(GoogleStaticMapsHelper::Location::NoLngMethod)
      end

      it "should raise NoLatMethod if object doesn't respond to lat" do
        lambda {GoogleStaticMapsHelper::Location.new(mock(:location, :lng => 20))}.should raise_error(GoogleStaticMapsHelper::Location::NoLatMethod)
      end
    end

    describe "get location from hash" do
      [:lat, :lng].each do |location_property|
        it "should extract #{location_property} from hash" do
          marker = GoogleStaticMapsHelper::Location.new(@location_hash)
          marker.send(location_property).should == @location_object.send(location_property)
        end
      end
      
      it "should raise NoLngKey if hash doesn't have key lng" do
        lambda {GoogleStaticMapsHelper::Location.new(:lat => 10)}.should raise_error(GoogleStaticMapsHelper::Location::NoLngKey)
      end

      it "should raise NoLatKey if hash doesn't have key lat" do
        lambda {GoogleStaticMapsHelper::Location.new(:lng => 20)}.should raise_error(GoogleStaticMapsHelper::Location::NoLatKey)
      end
    end
  end
end
