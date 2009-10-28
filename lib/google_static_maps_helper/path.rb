module GoogleStaticMapsHelper
  class Path
    include Enumerable

    OPTIONAL_OPTIONS = [:weight, :color, :fillcolor, :points]

    attr_accessor *OPTIONAL_OPTIONS

    def initialize(options = {})
      @points = []
      options.each_pair {|k, v| send("#{k}=", v)}
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
  end
end
