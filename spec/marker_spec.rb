require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Marker do
  before :each do
    @location = mock(:location, :lat => 10, :lng => 20)
  end

  it "should store a location which it will read it's location from" do
    location = GoogleStaticMapsHelper::Marker.new(@location)
    location.location.should == @location
  end

  it "should raise NoLngMethod if location object dosn't respond to lat" do
    lambda {GoogleStaticMapsHelper::Marker.new(mock(:location, :lat => 1))}.should raise_error(GoogleStaticMapsHelper::Marker::NoLngMethod)
  end

  it "should raise NoLatMethod if location object dosn't respond to lng" do
    lambda {GoogleStaticMapsHelper::Marker.new(mock(:location, :lng => 1))}.should raise_error(GoogleStaticMapsHelper::Marker::NoLatMethod)
  end
  
  it "should have a predefined color which location should use" do
    location = GoogleStaticMapsHelper::Marker.new(@location)
    location.options[:color].should == 'red'
  end

  it "should have a predefined size" do
    location = GoogleStaticMapsHelper::Marker.new(@location)
    location.options[:size].should == 'mid'
  end

  it "should have a predefined label which should be nil" do
    location = GoogleStaticMapsHelper::Marker.new(@location)
    location.options[:label].should be_nil
  end
end
