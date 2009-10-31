require 'uri'
require File.dirname(__FILE__) + '/google_static_maps_helper/map'
require File.dirname(__FILE__) + '/google_static_maps_helper/location'
require File.dirname(__FILE__) + '/google_static_maps_helper/marker'
require File.dirname(__FILE__) + '/google_static_maps_helper/path'

# 
# The Google Static Map Helper provides a simple interface to the
# Google Static Maps V2 API (http://code.google.com/apis/maps/documentation/staticmaps/).
#
# The module is build up of classes maping more or less directly to the entities you'd except:
# <tt>Map</tt>::      A map is what keeps all of the state of which you'll build a URL for.
# <tt>Marker</tt>::   One or more markers can be added to the map. A marker can be customized with size, label and color.
# <tt>Path</tt>::     A path will create lines or polygons in your map.
# 
# == About
#
# Author:: Thorbjørn Hermansen (thhermansen@gmail.com)
#
module GoogleStaticMapsHelper
  # The basic url to the API which we'll build the URL from
  API_URL = 'http://maps.google.com/maps/api/staticmap'

  class OptionMissing < ArgumentError; end # Raised when required options is not sent in during construction
  class OptionNotExist < ArgumentError; end # Raised when incoming options include keys which is invalid
  class BuildDataMissing < Exception; end # Raised when incoming options include keys which is invalid
  class UnsupportedFormat < ArgumentError; end # Raised when a format is not supported
  class UnsupportedMaptype < ArgumentError; end # Raised when the map type is not supported

  class << self
    attr_accessor :key, :size, :sensor
    
    #
    # Provides a simple DSL stripping away the need of manually instantiating classes
    #
    # Usage:
    #
    #   # First of all, you might want to set your key etc
    #   GoogleStaticMapsHelper.key = 'your google key'
    #   GoogleStaticMapsHelper.size = '300x600'
    #   GoogleStaticMapsHelper.sensor = false
    #   
    #   # Then, you'll be able to do:
    #   url = GoogleStaticMapsHelper.url_for do
    #     marker :lng => 1, :lat => 2
    #     marker :lng => 3, :lat => 4
    #     path {:lng => 5, :lat => 6}, {:lng => 7, :lat => 7}
    #   end
    #
    #   # You can send in key, size etc to url_for
    #   url = GoogleStaticMapsHelper.url_for(:key => 'your_key', :size => [300, 600]) do
    #     # ...
    #   end
    #
    #   # If you need to, the map object is yielded to the block, so you can do:
    #   url = GoogleStaticMapsHelper.url_for do |map|
    #     map.marker object_which_responds_to_lng_lat
    #   end
    #
    def url_for(map_options = {}, &block)
      map = Map.new(map_options)
      block.arity < 1 ? map.instance_eval(&block) : block.call(map)
      map.url
    end
  end
end
