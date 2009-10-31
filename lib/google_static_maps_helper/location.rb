module GoogleStaticMapsHelper
  #
  # Represents a location with lat and lng values.
  # 
  # This classed is used internally to back up Markers' location
  # and Paths' points.
  #
  class Location
    EARTH_RADIUS_KM = 6371 # :nodoc:

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
    # Calculates the distance in meters to given location
    #
    # <tt>location</tt>:: Another location which you want the distance to
    #
    def distance_to(location)
      dLat = deg2rad(location.lat - lat)
      dLon = deg2rad((location.lng - lng).abs)

      dPhi = Math.log(Math.tan(deg2rad(location.lat) / 2 + Math::PI / 4) / Math.tan(deg2rad(lat) / 2 + Math::PI / 4));
      q = (dLat.abs > 1e-10) ? dLat/dPhi : Math.cos(deg2rad(lat));

      dLon = 2 * Math::PI - dLon if (dLon > Math::PI) 
      d = Math.sqrt(dLat * dLat + q * q * dLon * dLon); 

      (d * EARTH_RADIUS_KM * 1000).round
    end

    #
    # Returns a new <tt>Location</tt> which has given distance and heading from current location
    #
    # <tt>distance</tt>::   The distance in meters for the new Location from current
    # <tt>heading</tt>::    The heading in degrees we should go from current
    #
    def endpoint(distance, heading)
      d = (distance / 1000.0) / EARTH_RADIUS_KM;
      heading = deg2rad(heading);

      oX = lng * Math::PI / 180;
      oY = lat * Math::PI / 180;

      y = Math.asin(Math.sin(oY) * Math.cos(d) + Math.cos(oY) * Math.sin(d) * Math.cos(heading));
      x = oX + Math.atan2(Math.sin(heading) * Math.sin(d) * Math.cos(oY), Math.cos(d) - Math.sin(oY) * Math.sin(y));

      y = y * 180 / Math::PI;
      x = x * 180 / Math::PI;

      self.class.new(:lat => y, :lng => x)
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

    def deg2rad(deg)
      deg * Math::PI / 180;
    end
  end
end
