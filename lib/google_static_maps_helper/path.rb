module GoogleStaticMapsHelper
  class Path
    include Enumerable

    OPTIONAL_OPTIONS = [:weight, :color, :fillcolor]

    attr_accessor :points, *OPTIONAL_OPTIONS

    def initialize(options = {})
      @points = []
      options.each_pair {|k, v| send("#{k}=", v)}
    end

    
    def url_params
      raise BuildDataMissing, "Need at least 2 points to create a path!" unless can_build?
      out = 'path='
     
      out += OPTIONAL_OPTIONS.inject([]) do |path_params, attribute|
        value = send(attribute)
        path_params << "#{attribute}:#{URI.escape(value.to_s)}" unless value.nil?
        path_params
      end.join('|')

      out += '|'

      out += inject([]) do |point_params, point|
        point_params << point.to_url
      end.join('|')
    end

  
    def points=(array)
      raise ArgumentError unless array.is_a? Array
      @points = []
      array.each {|point| self << point}
    end

    def each
      @points.each {|p| yield p}
    end

    def length
      @points.length
    end

    def empty?
      length == 0
    end

    def <<(point)
      @points << ensure_point_is_location_object(point)
      @points.uniq!
      self
    end

    private
    def ensure_point_is_location_object(point)
      return point if point.instance_of? Location
      Location.new(point)
    end

    def can_build?
      length > 1
    end
  end
end
