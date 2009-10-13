# coding:utf-8  
require File.dirname(__FILE__) + '/google_static_maps_helper/map'
require File.dirname(__FILE__) + '/google_static_maps_helper/marker'

module GoogleStaticMapsHelper
  API_URL = 'http://maps.google.com/maps/api/staticmap'

  class OptionMissing < ArgumentError; end # Raised when required options is not sent in during construction
  class OptionNotExist < ArgumentError; end # Raised when incoming options include keys which is invalid
  class BuildDataMissing < Exception; end # Raised when incoming options include keys which is invalid
end
