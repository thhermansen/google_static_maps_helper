require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper do
  describe "Friendly DSL API" do
    describe "url_for" do
      before do
        GoogleStaticMapsHelper.key = 'my_key'
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
        out = GoogleStaticMapsHelper.url_for(:size => '800x800') do
          marker :lat => 1, :lng => 2
        end

        out.should include('size=800x800')
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
