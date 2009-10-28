require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Path do
  describe "initialize" do
    @@options = {
      :weight => 5,
      :color => "0x0000ff",
      :fillcolor => "0x110000ff"
    }

    @@options.each_key do |attribute|
      it "should be able to set and retreive #{attribute} via initializer" do
        GoogleStaticMapsHelper::Path.new(@@options).send(attribute).should == @@options.fetch(attribute)
      end

      it "should be able to set and retreive #{attribute} via accessor method" do
        path = GoogleStaticMapsHelper::Path.new
        path.send("#{attribute}=", @@options.fetch(attribute))
        path.send(attribute).should == @@options.fetch(attribute)
      end
    end
  end

  describe "points" do
    before do
      @path = GoogleStaticMapsHelper::Path.new
      @point = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
      @point2 = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
    end

    it "should be an empty array of points after initialize" do
      @path.points.should == []
    end

    it "should be able to push points on to a path" do
      @path << @point
      @path.points.length.should == 1
      @path.points.first.should == @point
    end

    it "should not be able to push the same point twice" do
      @path << @point
      @path << @point
      @path.points.should == [@point]
    end

    it "should be able to chain push operator" do
      @path << @point << @point2
      @path.points.should == [@point, @point2]
    end

    it "should respond do each" do
      @path.should respond_to(:each)
    end

    it "should be able to tell it's length" do
      @path << @point << @point2
      @path.length.should == 2
    end

    it "should wrap a hash which contains lat and lng into a Location object when pushed" do
      @path << {:lat => 1, :lng => 2}
      @path.first.should be_an_instance_of(GoogleStaticMapsHelper::Location)
    end

    it "should raise an error if points setter doesn't receive an array" do
      lambda {@path.points = nil}.should raise_error(ArgumentError)
    end

    it "should make sure points-setter ensures that hash-values are wraped into a Location object" do
      @path.points = []
    end
  end
end
