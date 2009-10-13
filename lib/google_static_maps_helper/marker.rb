module GoogleStaticMapsHelper
  # Simple wrapper around an object which should respond to lat and lng.
  # The wrapper keeps track of additional parameters for the Google map
  # to be used, like size color and label.
  class Marker
    class NoLngMethod < NoMethodError; end
    class NoLatMethod < NoMethodError; end
    class NoLatKey < ArgumentError; end
    class NoLngKey < ArgumentError; end

    # These options are the one we build our parameters from
    DEFAULT_OPTIONS = {
      :color => 'red',
      :size => 'mid',
      :label => nil
    }

    attr_accessor :lat, :lng
    attr_reader :location, :options

    def initialize(*args)
      if args.first.is_a? Hash
        extract_location_from_hash!(args.first)
      else
        extract_location_from_object(args.shift)
      end

      options_from_args = args.shift || {}
      @options = DEFAULT_OPTIONS.merge(options_from_args)
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
