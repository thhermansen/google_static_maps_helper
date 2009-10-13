module GoogleStaticMapsHelper
  # Represents the map we are generating
  # It holds markers and iterates over them to build the URL
  # to be used in an image tag.
  class Map
    include Enumerable

    # Raised when required options is not sent in during construction
    class OptionMissing < ArgumentError; end
    
    REQUIRED_OPTIONS = [:key, :size, :sensor]
    OPTIONAL_OPTIONS = [:center, :zoom, :size, :format, :maptype, :mobile, :language]
    
    def initialize(options)
      validate_required_options(options)

      @markers = []
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
    
    private
    def validate_required_options(options)
      missing_options = REQUIRED_OPTIONS - options.keys
      raise OptionMissing, "The following required options are missing: #{missing_options.join(', ')}" unless missing_options.empty?
    end
  end
end
