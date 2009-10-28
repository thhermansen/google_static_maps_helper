module GoogleStaticMapsHelper
  # Represents the map we are generating
  # It holds markers and paths and iterates over them to build the URL
  # to be used in an image tag.
  class Map
    include Enumerable

    MAX_WIDTH = 640
    MAX_HEIGHT = 640

    VALID_FORMATS = %w{png png8 png32 gif jpg jpg-basedline}
    VALID_MAP_TYPES = %w{roadmap satellite terrain hybrid}

    REQUIRED_OPTIONS = [:key, :size, :sensor]
    OPTIONAL_OPTIONS = [:center, :zoom, :format, :maptype, :mobile, :language, :format, :maptype]
    
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
      @map_enteties = []
    end

    def url
      raise BuildDataMissing, "We have to have markers, paths or center and zoom set when url is called!" unless can_build?
      
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
      
      params = []
      paths.each {|path| params << path.url_params}
      out += "&#{params.join('&')}" unless params.empty?

      out
    end

    def markers
      @map_enteties.select {|e| e.is_a? Marker}
    end

    def grouped_markers
      markers.inject(Hash.new {|hash, key| hash[key] = []}) do |groups, marker|
        groups[marker.options_to_url_params] << marker
        groups
      end
    end

    def paths
      @map_enteties.select {|e| e.is_a? Path}
    end
    
    def <<(entity)
      @map_enteties << entity
      @map_enteties.uniq!
      self
    end

    def each
      @map_enteties.each {|m| yield(m)}
    end

    def empty?
      @map_enteties.empty?
    end

    def length
      @map_enteties.length
    end

    def marker(*args)
      marker = Marker.new(*args)
      self << marker
    end
    
    def size=(size)
      unless size.nil?
        case size
        when String
          width, height = size.split('x')
        when Array
          width, height = size
        when Hash
          width = size[:width]
          height = size[:height]
        else
          raise "Don't know how to set size from #{size.class}!"
        end

        self.width = width if width
        self.height = height if height
      end
    end

    def size
      [@width, @height].join('x')
    end

    [:width, :height].each do |name|
      define_method "#{name}=" do |dimension|
        dimension = dimension.to_i
        max_dimension = self.class.const_get("MAX_#{name.to_s.upcase}")
        raise "Incomming dimension (#{dimension}) above max limit (#{max_dimension})." if dimension > max_dimension
        instance_variable_set("@#{name}", dimension)
      end
    end

    def format=(format)
      @format = format.to_s
      raise UnsupportedFormat unless VALID_FORMATS.include? @format
    end

    def maptype=(type)
      @maptype = type.to_s
      raise UnsupportedMaptype unless VALID_MAP_TYPES.include? @maptype
    end


    private
    def can_build?
      !@map_enteties.empty? || (center && zoom)
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
