# -*- encoding: utf-8 -*-
module GoogleStaticMapsHelper
  #
  # The Map keeps track of the state of which we want to build a URL for.
  # It will hold Markers and Paths, and other states like dimensions of the map,
  # image format, language etc.
  #
  class Map
    include Enumerable
    
    MAX_WIDTH = 640
    MAX_HEIGHT = 640

    VALID_FORMATS = %w{png png8 png32 gif jpg jpg-basedline}
    VALID_MAP_TYPES = %w{roadmap satellite terrain hybrid}

    REQUIRED_OPTIONS = [:key, :size, :sensor]
    OPTIONAL_OPTIONS = [:center, :zoom, :format, :maptype, :mobile, :language]
    
    attr_accessor *(REQUIRED_OPTIONS + OPTIONAL_OPTIONS)
    attr_accessor :width, :height

    #
    # Creates a new Map object
    #
    # <tt>:options</tt>::   The options available are the same as described in
    #                       Google's API documentation[http://code.google.com/apis/maps/documentation/staticmaps/#Usage].
    #                       In short, valid options are:
    #                       <tt>:key</tt>::       Your Google maps API key
    #                       <tt>:size</tt>::      The size of the map. Can be a "wxh", [w,h] or {:width => x, :height => y}
    #                       <tt>:sensor</tt>::    Set to true if your application is using a sensor. See the API doc.
    #                       <tt>:center</tt>::    The center point of your map. Optional if you add markers or path to the map
    #                       <tt>:zoom</tt>::      The zoom level you want, also optional as center
    #                       <tt>:format</tt>::    Defaults to png
    #                       <tt>:maptype</tt>::   Defaults to roadmap
    #                       <tt>:mobile</tt>::    Returns map tiles better suited for mobile devices with small screens.
    #                       <tt>:language</tt>::  The language used in the map
    #
    def initialize(options = {})
      inject_defaults_from_module_class_attribute!(options)
      validate_required_options(options)
      validate_options(options)

      options.each_pair { |k, v| send("#{k}=", v) }
      @map_enteties = []
    end

    #
    # Builds up a URL representing the state of this Map object
    #
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

    #
    # Returns all the markers which this map holds
    #
    def markers
      @map_enteties.select {|e| e.is_a? Marker}
    end

    #
    # Returns the markers grouped by it's label, color and size.
    #
    # This is handy when building the URL because the API wants us to
    # group together equal markers and just list the position of the markers thereafter in the URL.
    #
    def grouped_markers
      markers.inject(Hash.new {|hash, key| hash[key] = []}) do |groups, marker|
        groups[marker.options_to_url_params] << marker
        groups
      end
    end

    # 
    # Returns all the paths which this map holds
    #
    def paths
      @map_enteties.select {|e| e.is_a? Path}
    end
    
    #
    # Pushes either a Marker or a Path on to the map
    #
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

    #
    # Used internally to make the DSL work. Might be changed at any time
    # to make a better implementation.
    #
    def marker(*args) # :nodoc:
      self << Marker.new(*args)
    end

    #
    # Used internally to make the DSL work. Might be changed at any time
    #
    def path(*args) # :nodoc:
      self << Path.new(*args)
    end
    
    #
    # Sets the size of the map
    #
    # <tt>size</tt>::   Can be a "wxh", [w,h] or {:width => x, :height => y}
    #
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
    
    #
    # Returns size as a string, "wxh"
    #
    def size
      [@width, @height].join('x')
    end
    
    #
    # Defines width and height setter methods
    #
    # These methods enforces the MAX dimensions of the map
    #
    [:width, :height].each do |name|
      define_method "#{name}=" do |dimension|
        dimension = dimension.to_i
        max_dimension = self.class.const_get("MAX_#{name.to_s.upcase}")
        raise "Incomming dimension (#{dimension}) above max limit (#{max_dimension})." if dimension > max_dimension
        instance_variable_set("@#{name}", dimension)
      end
    end


    #
    # Sets the format of the map
    #
    # <tt>format</tt>:: Can be any values included in VALID_FORMATS.
    #
    def format=(format)
      @format = format.to_s
      raise UnsupportedFormat unless VALID_FORMATS.include? @format
    end

    #
    # Sets the map type of the map
    #
    # <tt>type</tt>:: Can be any values included in VALID_MAP_TYPES.
    #
    def maptype=(type)
      @maptype = type.to_s
      raise UnsupportedMaptype unless VALID_MAP_TYPES.include? @maptype
    end


    private
    #
    # Returns an answer for if we can build the URL or not
    #
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
