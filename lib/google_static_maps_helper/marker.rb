module GoogleStaticMapsHelper
  # Simple wrapper around an object which should respond to lat and lng.
  # The wrapper keeps track of additional parameters for the Google map
  # to be used, like size color and label.
  class Marker
    class NoLngMethod < NoMethodError; end
    class NoLatMethod < NoMethodError; end

    # These options are the one we build our parameters from
    DEFAULT_OPTIONS = {
      :color => 'red',
      :size => 'mid',
      :label => nil
    }

    attr_reader :location, :options

    def initialize(location, options = {})
      @location = location
      @options = DEFAULT_OPTIONS.merge(options)

      validate_location
    end


    private
    def validate_location
      raise NoLngMethod unless location.respond_to? :lng
      raise NoLatMethod unless location.respond_to? :lat
    end
  end
end
