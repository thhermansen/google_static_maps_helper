# -*- encoding: utf-8 -*-
module GoogleStaticMapsHelper
  #
  # A marker object is representing a marker with a customizable label, color and size.
  #
  class Marker
    DEFAULT_OPTIONS = {
      :color => 'red',
      :size => 'mid',
      :label => nil,
      :icon => nil,
      :shadow => nil
    }

    attr_accessor :location, *DEFAULT_OPTIONS.keys

    # :call-seq:
    #   new(location_object_or_options, *args)
    #
    # Creates a new Marker object. A marker object will, when added to a Map, represent
    # one marker which you can customize with color, size and label.
    #
    # <tt>:location_object_or_options</tt>::  Either an object which responds to lat and lng or simply a option hash
    # <tt>:args</tt>::                        A hash of options. Can have keys like <tt>:color</tt>,
    #                                         <tt>:size</tt>, and <tt>:label</tt>.
    #                                         See Google's API documentation[http://code.google.com/apis/maps/documentation/staticmaps/#MarkerStyles] for more information.
    #                                         If a location object hasn't been given you must also include <tt>:lat</tt>
    #                                         and <tt>:lng</tt> values.
    #
    #
    # Usage:
    #
    #   # Sets location via object which responds to lng and lat
    #   GoogleStaticMapsHelper::Marker.new(location {:label => :a})
    #   
    #   # ..or include the lng and lat in the option hash
    #   GoogleStaticMapsHelper::Marker.new(:lng => 1, :lat => 2, :label => :a)
    #
    def initialize(*args)
      raise ArgumentError, "Must have one or two arguments." if args.length == 0
      extract_location!(args)
      options = DEFAULT_OPTIONS.merge(args.shift || {})
      validate_options(options)
      options.each_pair { |k, v| send("#{k}=", v) }
    end

    # 
    # Returns a string representing this marker
    # Used by the Map when building url.
    #
    def options_to_url_params # :nodoc:
      params = DEFAULT_OPTIONS.keys.map(&:to_s).sort.inject([]) do |params, attr|
        primary_getter = "#{attr}_to_be_used_in_param"
        secondary_getter = attr

        value = send(primary_getter) rescue send(secondary_getter)
        params << "#{attr}:#{URI.escape(value.to_s)}" unless value.nil?
        params
      end

      params.join('|')
    end

    # 
    # Concatenation of lat and lng value. Used when building URLs and returns them in correct order
    #
    def location_to_url # :nodoc:
      @location.to_url
    end
    
    def label # :nodoc:
      @label.to_s.upcase if @label
    end

    def color # :nodoc:
      @color.downcase if @color
    end

    def has_icon?
      !!@icon
    end


    #
    # Proxies calls to the internal object which keeps track of this marker's location.
    # So, if @location responds to method missing in this object, it will respond to it.
    #
    def method_missing(method, *args)
      return @location.send(method, *args) if @location.respond_to? method
      super
    end

    private
    def extract_location!(args)
      @location = Location.new(*args)
      args.shift unless args.first.is_a? Hash
    end

    def validate_options(options)
      invalid_options = options.keys - DEFAULT_OPTIONS.keys
      raise OptionNotExist, "The following options does not exist: #{invalid_options.join(', ')}" unless invalid_options.empty?
    end

    # Some attributes should be nil when a marker has icon
    [:color, :label, :size].each do |getter|
      define_method "#{getter}_to_be_used_in_param" do
        return nil if has_icon? 
        send(getter)
      end
    end
  end
end
