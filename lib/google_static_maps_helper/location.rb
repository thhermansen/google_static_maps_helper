module GoogleStaticMapsHelper
  #
  # Represents a location with lat and lng values.
  # 
  # This classed is used internally to back up Markers' location
  # and Paths' points.
  #
  class Location
    LAT_LNG_PRECISION = 6 # :nodoc:

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


    [:lng, :lat].each do |attr|
      define_method("#{attr}=") do |value|
        instance_variable_set("@#{attr}", lng_lat_to_precision(value, LAT_LNG_PRECISION))
      end
    end

    private
    def extract_location_from_hash!(location_hash)
      raise NoLngKey unless location_hash.has_key? :lng
      raise NoLatKey unless location_hash.has_key? :lat
      self.lat = location_hash.delete(:lat)
      self.lng = location_hash.delete(:lng)
    end

    def extract_location_from_object(location)
      raise NoLngMethod unless location.respond_to? :lng
      raise NoLatMethod unless location.respond_to? :lat
      self.lat = location.lat
      self.lng = location.lng
    end

    def lng_lat_to_precision(number, precision)
      rounded = (Float(number) * 10**precision).round.to_f / 10**precision
      rounded = rounded.to_i if rounded.to_i == rounded
      rounded
    end
  end
end
