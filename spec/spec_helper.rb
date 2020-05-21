# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'google_static_maps_helper'
require 'rspec'

RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = :should
    end
    config.mock_with :rspec do |c|
      c.syntax = :should
    end
  end
