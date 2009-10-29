module GoogleStaticMapsHelper
  #
  # Represents a location with lat and lng values.
  # 
  # This classed is used internally to back up Markers' location
  # and Paths' points.
  #
  class Location
    class NoLngMethod < NoMethodError; end # Raised if incomming object doesnt respond to lng
    class NoLatMethod < NoMethodError; end # Raised if incomming object doesnt respond to lat
    class NoLatKey < ArgumentError; end # Raised if incomming Hash doesnt have key lat
    class NoLngKey < ArgumentError; end # Raised if incomming Hash doesnt have key lng

    attr_accessor :lat, :lng

    # :call-seq:
    #   new(location_object_or_options, *args)
    #
    # Creates a new Location which is used by Marker and Path object
    # to represent it's locations.
    #
    # <tt>:args</tt>: Either a location which responds to lat or lng, or a Hash which has :lat and :lng keys.
    #
    def initialize(*args)
      raise ArgumentError, "Must have some arguments." if args.length == 0
      
      if args.first.is_a? Hash
        extract_location_from_hash!(args.first)
      else
        extract_location_from_object(args.shift)
      end
    end
    
    #
    # Returning the location as a string "lat,lng"
    #
    def to_url # :nodoc:
      [lat, lng].join(',')
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
