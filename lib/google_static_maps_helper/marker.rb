module GoogleStaticMapsHelper
  # Simple wrapper around an object which should respond to lat and lng.
  # The wrapper keeps track of additional parameters for the Google map
  # to be used, like size color and label.
  class Marker
    # These options are the one we build our parameters from
    DEFAULT_OPTIONS = {
      :color => 'red',
      :size => 'mid',
      :label => nil
    }

    attr_accessor :location, *DEFAULT_OPTIONS.keys

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
      @location.to_url
    end
    
    def label
      @label.to_s.upcase if @label
    end

    def color
      @color.downcase if @color
    end


    def method_missing(method, *args)
      return @location.send(method, *args) if @location.respond_to? method
      super
    end

    private
    def extract_location_from_hash!(location_hash)
      to_object = {}
      to_object[:lat] = location_hash.delete :lat if location_hash.has_key? :lat
      to_object[:lng] = location_hash.delete :lng if location_hash.has_key? :lng
      @location = Location.new(to_object)
    end

    def extract_location_from_object(location)
      @location = Location.new(location)
    end

    def validate_options(options)
      invalid_options = options.keys - DEFAULT_OPTIONS.keys
      raise OptionNotExist, "The following options does not exist: #{invalid_options.join(', ')}" unless invalid_options.empty?
    end
  end
end
