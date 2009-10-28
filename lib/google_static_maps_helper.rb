require 'uri'
require File.dirname(__FILE__) + '/google_static_maps_helper/map'
require File.dirname(__FILE__) + '/google_static_maps_helper/location'
require File.dirname(__FILE__) + '/google_static_maps_helper/marker'
require File.dirname(__FILE__) + '/google_static_maps_helper/path'

module GoogleStaticMapsHelper
  API_URL = 'http://maps.google.com/maps/api/staticmap'

  class OptionMissing < ArgumentError; end # Raised when required options is not sent in during construction
  class OptionNotExist < ArgumentError; end # Raised when incoming options include keys which is invalid
  class BuildDataMissing < Exception; end # Raised when incoming options include keys which is invalid
  class UnsupportedFormat < ArgumentError; end # Raised when a format is not supported
  class UnsupportedMaptype < ArgumentError; end # Raised when the map type is not supported

  class << self
    attr_accessor :key, :size, :sensor

    def url_for(map_options = {}, &block)
      map = Map.new(map_options)
      block.arity < 1 ? map.instance_eval(&block) : block.call(map)
      map.url
    end
  end
end
