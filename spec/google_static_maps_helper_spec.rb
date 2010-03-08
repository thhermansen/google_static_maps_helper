# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper do
  describe "Friendly DSL API" do
    describe "url_for" do
      before do
        GoogleStaticMapsHelper.size = '300x500'
        GoogleStaticMapsHelper.sensor = false
      end

      it "should have a responding method" do
        GoogleStaticMapsHelper.respond_to?(:url_for).should be_true
      end

      it "should be possible to add markers to map through a b block" do
        out = GoogleStaticMapsHelper.url_for do
          marker :lat => 1, :lng => 2
        end

        out.should include('markers=color:red|size:mid|1,2')
      end

      it "should be possible to override the default map construction values" do
        out = GoogleStaticMapsHelper.url_for(:size => '600x400') do
          marker :lat => 1, :lng => 2
        end

        out.should include('size=600x400')
      end

      it "should be able to add paths" do
        point = {:lat => 1, :lng => 2}
        point2 = {:lat => 3, :lng => 4}

        out = GoogleStaticMapsHelper.url_for do
          path point, point2, :color => :red, :encode_points => false
        end

        out.should include('path=color:red|1,2|3,4')
      end

      it "should be possible to use inside a class, using attributes of that class" do
        class TestingClass
          attr_reader :location

          def initialize
            @location = {:lat => 1, :lng => 5} 
          end

          def url
            GoogleStaticMapsHelper.url_for do |map|
              map.marker location
            end
          end
        end

        TestingClass.new.url.should include('markers=color:red|size:mid|1,5')
      end
    end
  end
end
