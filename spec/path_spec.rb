# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Path do
  options = {
    :weight => 5,
    :color => "0x0000ff",
    :fillcolor => "0x110000ff"
  }

  describe "initialize" do
    options.each_key do |attribute|
      it "should be able to set and retreive #{attribute} via initializer" do
        GoogleStaticMapsHelper::Path.new(options).send(attribute).should == options.fetch(attribute)
      end

      it "should be able to set and retreive #{attribute} via accessor method" do
        path = GoogleStaticMapsHelper::Path.new
        path.send("#{attribute}=", options.fetch(attribute))
        path.send(attribute).should == options.fetch(attribute)
      end
    end

    describe "encoding points flag" do
      it "should be able to set to false" do
        path = GoogleStaticMapsHelper::Path.new(:encode_points => false)
        path.should_not be_encoding_points
      end

      it "should be able to set to true" do
        path = GoogleStaticMapsHelper::Path.new(:encode_points => true)
        path.should be_encoding_points
      end

      it "should be true as default" do
        path = GoogleStaticMapsHelper::Path.new
        path.should be_encoding_points
      end
    end

    describe "points" do
      before do
        @point = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
        @point2 = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
      end

      it "should be able to add points via options during initialization" do
        path = GoogleStaticMapsHelper::Path.new(options.merge(:points => [@point, @point2]))
        path.points.should == [@point, @point2]
      end

      it "should be able to add points before option hash" do
        path = GoogleStaticMapsHelper::Path.new(@point, @point2, options)
        path.points.should == [@point, @point2]
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

    it "should be possible to clear points" do
      @path << @point << @point2
      @path.clear
      @path.length.should == 0
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

    it "should be able to answer empty?" do
      @path.should be_empty
    end

    it "should wrap a hash which contains lat and lng into a Location object when pushed" do
      @path << {:lat => 1, :lng => 2}
      @path.first.should be_an_instance_of(GoogleStaticMapsHelper::Location)
    end

    it "should fetch lat and lng values from any object which responds to it" do
      @path << double(:point, :lat => 1, :lng => 2)
      @path.first.should be_an_instance_of(GoogleStaticMapsHelper::Location)
    end

    it "should raise an error if points setter doesn't receive an array" do
      lambda {@path.points = nil}.should raise_error(ArgumentError)
    end

    it "should make sure points-setter ensures that hash-values are wraped into a Location object" do
      @path.points = []
    end
  end


  describe "url_params" do
    before do
      @path = GoogleStaticMapsHelper::Path.new :encode_points => false
      @point = GoogleStaticMapsHelper::Location.new(:lat => 1, :lng => 2)
      @point2 = GoogleStaticMapsHelper::Location.new(:lat => 3, :lng => 4)
      @path << @point << @point2
    end

    it "should respond to url_params" do
      @path.should respond_to(:url_params)
    end

    it "should raise an error if a path doesn't include any points" do
      @path.points = []
      lambda {@path.url_params}.should raise_error(GoogleStaticMapsHelper::BuildDataMissing)
    end

    it "should not raise an error if path have points" do
      lambda {@path.url_params}.should_not raise_error(GoogleStaticMapsHelper::BuildDataMissing)
    end

    it "should begin with path=" do
      @path.url_params.should match(/^path=/)
    end

    it "should include points' locations" do
      @path.url_params.should include('1,2')
    end

    options.each do |attribute, value|
      it "should not include #{attribute} as default in url" do
        @path.url_params.should_not include("#{attribute}=")
      end

      it "should include #{attribute} when set on path" do
        @path.send("#{attribute}=", value)
        @path.url_params.should include("#{attribute}:#{value}")
      end
    end

    it "should concat path options and point locations correctly together" do
      @path.weight = 3
      @path.url_params.should == 'path=weight:3|1,2|3,4'
    end

    it "should concat point locations without any path options" do
      @path.url_params.should == 'path=1,2|3,4'
    end

    describe "encoded poly lines" do
      before do
        @path.encode_points = true
      end

      it "should include 'enc:'" do
        @path.url_params.should include('enc:')
      end

      it "should include encoded version of lng and lat" do
        @path.url_params.should include('_ibE_seK_seK_seK')
      end
    end
  end
end
