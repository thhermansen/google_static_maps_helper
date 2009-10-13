module GoogleStaticMapsHelper
  # Represents the map we are generating
  # It holds markers and iterates over them to build the URL
  # to be used in an image tag.
  class Map
    include Enumerable

    REQUIRED_OPTIONS = [:key, :size, :sensor]
    OPTIONAL_OPTIONS = [:center, :zoom, :size, :format, :maptype, :mobile, :language]
    
    attr_reader :options

    def initialize(options)
      validate_required_options(options)
      validate_options(options)

      @options = options
      @markers = []
    end

    def url
      raise BuildDataMissing, "We have to have markers or center and zoom set when url is called!" unless can_build?
    end
    
    def <<(marker)
      @markers << marker
      @markers.uniq!
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

    def method_missing(method, *args, &block)
      return options[method] if options.has_key? method
      super
    end
    

    private
    def can_build?
      !@markers.empty? || (options[:center] && options[:zoom])
    end

    def validate_required_options(options)
      missing_options = REQUIRED_OPTIONS - options.keys
      raise OptionMissing, "The following required options are missing: #{missing_options.join(', ')}" unless missing_options.empty?
    end

    def validate_options(options)
      invalid_options = options.keys - REQUIRED_OPTIONS - OPTIONAL_OPTIONS
      raise OptionNotExist, "The following options does not exist: #{invalid_options.join(', ')}" unless invalid_options.empty?
    end
  end
end
