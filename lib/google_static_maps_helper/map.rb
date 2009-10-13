module GoogleStaticMapsHelper
  # Represents the map we are generating
  # It holds markers and iterates over them to build the URL
  # to be used in an image tag.
  class Map
    # Raised when required options is not sent in during construction
    class OptionMissing < ArgumentError; end
    
    REQUIRED_OPTIONS = [:key, :size, :sensor]


    def initialize(options)
      validate_required_options(options)
    end


    private
    def validate_required_options(options)
      missing_options = REQUIRED_OPTIONS - options.keys
      raise OptionMissing, "The following required options are missing: #{missing_options.join(', ')}" unless missing_options.empty?
    end
  end
end
