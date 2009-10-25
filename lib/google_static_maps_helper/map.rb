module GoogleStaticMapsHelper
  # Represents the map we are generating
  # It holds markers and iterates over them to build the URL
  # to be used in an image tag.
  class Map
    include Enumerable

    REQUIRED_OPTIONS = [:key, :size, :sensor]
    OPTIONAL_OPTIONS = [:center, :zoom, :format, :maptype, :mobile, :language]
    
    attr_accessor *(REQUIRED_OPTIONS + OPTIONAL_OPTIONS)
    attr_accessor :width, :height

    # Initialize a new Map object
    #
    # Takes a hash of options where :key, :size and :sensor are required.
    # Other options are center, zoom, format, maptype, mobile and language
    def initialize(options)
      inject_defaults_from_module_class_attribute!(options)
      validate_required_options(options)
      validate_options(options)

      options.each_pair { |k, v| send("#{k}=", v) }
      @markers = []
    end

    def url
      raise BuildDataMissing, "We have to have markers or center and zoom set when url is called!" unless can_build?
      
      out = "#{API_URL}?"

      params = []
      (REQUIRED_OPTIONS + OPTIONAL_OPTIONS).each do |key|
        value = send(key)
        params << "#{key}=#{URI.escape(value.to_s)}" unless value.nil?
      end
      out += params.join('&')

      params = []
      grouped_markers.each_pair do |marker_options_as_url_params, markers|
        markers_locations = markers.map { |m| m.location_to_url }.join('|')
        params << "markers=#{marker_options_as_url_params}|#{markers_locations}"
      end
      out += "&#{params.join('&')}" unless params.empty?

      out
    end

    def grouped_markers
      inject(Hash.new {|hash, key| hash[key] = []}) do |groups, marker|
        groups[marker.options_to_url_params] << marker
        groups
      end
    end
    
    def <<(marker)
      @markers << marker
      @markers.uniq!
      self
    end

    def each
      @markers.each {|m| yield(m)}
    end

    def empty?
      @markers.empty?
    end

    def length
      @markers.length
    end

    def marker(*args)
      marker = Marker.new(*args)
      self << marker
    end
    
    def size=(size)
      unless size.nil?
        width, height = size.split('x')
        self.width = width
        self.height = height
      end
    end

    def size
      [@width, @height].join('x')
    end

    [:width, :height].each do |name|
      define_method "#{name}=" do |dimension|
        instance_variable_set("@#{name}", dimension.to_i)
      end
    end

    private
    def can_build?
      !@markers.empty? || (center && zoom)
    end

    def validate_required_options(options)
      missing_options = REQUIRED_OPTIONS - options.keys
      raise OptionMissing, "The following required options are missing: #{missing_options.join(', ')}" unless missing_options.empty?
    end

    def validate_options(options)
      invalid_options = options.keys - REQUIRED_OPTIONS - OPTIONAL_OPTIONS
      raise OptionNotExist, "The following options does not exist: #{invalid_options.join(', ')}" unless invalid_options.empty?
    end

    def inject_defaults_from_module_class_attribute!(options)
      REQUIRED_OPTIONS.each do |option_key|
        next if options.has_key? option_key
        value_from_modul = GoogleStaticMapsHelper.send(option_key)
        options[option_key] = value_from_modul unless value_from_modul.nil?
      end
    end
  end
end
