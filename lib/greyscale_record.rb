require "greyscale_record/version"
require 'active_model'
require 'active_model/model'
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash'
require 'yaml'

module GreyscaleRecord
  autoload :Associatable,   'greyscale_record/associatable'
  autoload :Associations,   'greyscale_record/associations'
  autoload :Base,           'greyscale_record/base'
  autoload :Cacheable,      'greyscale_record/cacheable'
  autoload :DataStore,      'greyscale_record/data_store'
  autoload :Drivers,        'greyscale_record/drivers'
  autoload :Errors,         'greyscale_record/errors'
  autoload :Instanceable,   'greyscale_record/instanceable'
  autoload :Indexable,      'greyscale_record/indexable'
  autoload :Propertiable,   'greyscale_record/propertiable'
  autoload :Queriable,      'greyscale_record/queriable'
  autoload :Scope,          'greyscale_record/scope'

  class << self
    attr_accessor :live_reload
    attr_accessor :logger
  end

  self.live_reload  = false
  self.logger       = Logger.new(STDOUT)
end
