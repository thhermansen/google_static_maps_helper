module GoogleStaticMapsHelper

# Represents a location (latitude and longitude)
#
# This class will also hold logic like travel_to(heading, distance) which will make
# drawing paths and polygons easier.
  class Location
    class NoLngMethod < NoMethodError; end
    class NoLatMethod < NoMethodError; end
    class NoLatKey < ArgumentError; end
    class NoLngKey < ArgumentError; end

    attr_accessor :lat, :lng

    def initialize(*args)
      raise ArgumentError, "Must have some arguments." if args.length == 0
      
      if args.first.is_a? Hash
        extract_location_from_hash!(args.first)
      else
        extract_location_from_object(args.shift)
      end
    end

    
    private
    def extract_location_from_hash!(location_hash)
      raise NoLngKey unless location_hash.has_key? :lng
      raise NoLatKey unless location_hash.has_key? :lat
      @lat = location_hash.delete(:lat)
      @lng = location_hash.delete(:lng)
    end

    def extract_location_from_object(location)
      raise NoLngMethod unless location.respond_to? :lng
      raise NoLatMethod unless location.respond_to? :lat
      @lat = location.lat
      @lng = location.lng
    end
  end
end
