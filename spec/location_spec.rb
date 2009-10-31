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

  it "should return to_url with its lat and lng value" do
    GoogleStaticMapsHelper::Location.new(@location_hash).to_url.should == '10,20'
  end



  describe "helper methods" do
    [
      [{:lat => 60, :lng => 0}, 0],
      [{:lat => 60, :lng => 1}, 55597],
      [{:lat => 61, :lng => 0}, 111195],
      [{:lat => 60, :lng => 0.01}, 556]
    ].each do |point_distance|
      it "should calculate correct distance to another location" do
        another_point, expected_distance = point_distance
        base = GoogleStaticMapsHelper::Location.new(:lat => 60, :lng => 0)
        another_point = GoogleStaticMapsHelper::Location.new(another_point)
        base.distance_to(another_point).should == expected_distance
      end
    end


    [
      [1000, 360, {:lat => 59.841957967464396, :lng => 10.43930343610808}],
      [1000, 324, {:lat => 59.84023999640559, :lng => 10.428782049078075}],
      [1000, 114, {:lat => 59.829305867622345, :lng=> 10.455650579695265}],
      [1000, 18, {:lat => 59.84151769215414, :lng => 10.44483506887988}]
    ].each do |distance_heading_new_point|
      it "should calculate new end point with given distance and heading" do
        distance, heading, excpexted_point = distance_heading_new_point
        base = GoogleStaticMapsHelper::Location.new(:lat => 59.832964751405214, :lng => 10.439303436108082)
        new_point = base.endpoint(distance, heading)

        new_point.lat.should == excpexted_point[:lat]
        new_point.lng.should == excpexted_point[:lng]
      end
    end
  end
end
