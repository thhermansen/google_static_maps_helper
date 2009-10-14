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

    attr_accessor :lat, :lng, *DEFAULT_OPTIONS.keys

    # Initialize a new Marker 
    # 
    # Can wither take an object which responds to lng and lat
    # GoogleStaticMapsHelper::Marker.new(location)
    #
    # Or it can take a has which includes lng and lat
    # GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2)
    #
    # You can also send in options like color, size and label in the hash,
    # or as a secnond parameter if the first was an object.
    def initialize(*args)
      raise ArgumentError, "Must have one or two arguments." if args.length == 0

      if args.first.is_a? Hash
        extract_location_from_hash!(args.first)
      else
        extract_location_from_object(args.shift)
      end

      options = DEFAULT_OPTIONS.merge(args.shift || {})
      validate_options(options)
      options.each_pair { |k, v| send("#{k}=", v) }
    end

    # Returns a string wich is what Google Static map is using to
    # set the style on the marker. This ill include color, size and label
    def options_to_url_params
      params = DEFAULT_OPTIONS.keys.map(&:to_s).sort.inject([]) do |params, attr|
        value = send(attr)
        params << "#{attr}:#{URI.escape(value)}" unless value.nil?
        params
      end

      params.join('|')
    end

    # Concatination of lat and lng value, used when building the url
    def location_to_url
      [lat, lng].join(',')
    end
    
    def label
      @label.to_s.upcase if @label
    end

    def color
      @color.downcase if @color
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

    def validate_options(options)
      invalid_options = options.keys - DEFAULT_OPTIONS.keys
      raise OptionNotExist, "The following options does not exist: #{invalid_options.join(', ')}" unless invalid_options.empty?
    end
  end
end
