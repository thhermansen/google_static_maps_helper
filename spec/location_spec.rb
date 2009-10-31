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

  describe "reduce and round off lng and lat" do
    before do
      @location = GoogleStaticMapsHelper::Location.new(:lng => 0, :lat => 1)
    end

    [:lng, :lat].each do |attribute|
      it "should not round #{attribute} when it is a number with a precision less than 6" do
        @location.send("#{attribute}=", 12.000014)
        @location.send(attribute).should == 12.000014
      end

      it "should round #{attribute} when it is a number with a precision above 6" do
        @location.send("#{attribute}=", 12.0000051)
        @location.send(attribute).should == 12.000005
      end

      it "should round and reduce #{attribute} when it's value is a float which can be represented with a descrete value" do
        @location.send("#{attribute}=", 12.00000000001)
        @location.send(attribute).to_s.should == "12"
      end
    end
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
      [1000, 360, {:lat => 59.841958, :lng => 10.439303}],
      [1000, 324, {:lat => 59.84024, :lng => 10.428782}],
      [1000, 114, {:lat => 59.829306, :lng=> 10.45565}],
      [1000, 18, {:lat => 59.841518, :lng => 10.444835}]
    ].each do |distance_heading_new_point|
      it "should calculate new end point with given distance and heading" do
        distance, heading, excpexted_point = distance_heading_new_point
        base = GoogleStaticMapsHelper::Location.new(:lat => 59.832964751405214, :lng => 10.439303436108082)
        new_point = base.endpoint(distance, heading)

        new_point.lat.should == excpexted_point[:lat]
        new_point.lng.should == excpexted_point[:lng]
      end
    end

    it "should return endpoints for a circle with given radius, 60 as default" do
      base = GoogleStaticMapsHelper::Location.new(:lat => 59.832964751405214, :lng => 10.439303436108082)
      endpoints = base.endpoints_for_circle_with_radius(1000)
      endpoints.length.should == 60
    end

    it "should reley on endpoint method to calculate new endpoints when creating circle points" do
      base = GoogleStaticMapsHelper::Location.new(:lat => 59.832964751405214, :lng => 10.439303436108082)
      base.should_receive(:endpoint).with(1000, 0 * 360 / 4)
      base.should_receive(:endpoint).with(1000, 1 * 360 / 4)
      base.should_receive(:endpoint).with(1000, 2 * 360 / 4)
      base.should_receive(:endpoint).with(1000, 3 * 360 / 4)
      endpoints = base.endpoints_for_circle_with_radius(1000, 4)
    end

    it "should raise argument error if number of points asked to returned when creating a circle is above 360" do
      base = GoogleStaticMapsHelper::Location.new(:lat => 59, :lng => 10)
      lambda {base.endpoints_for_circle_with_radius(1000, 361)}.should raise_error(ArgumentError)
    end

    it "should raise argument error if number of points asked to returned when creating a circle is less than 10" do
      base = GoogleStaticMapsHelper::Location.new(:lat => 59, :lng => 10)
      lambda {base.endpoints_for_circle_with_radius(1000, 0)}.should raise_error(ArgumentError)
    end
  end
end
