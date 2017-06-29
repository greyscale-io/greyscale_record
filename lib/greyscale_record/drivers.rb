module GreyscaleRecord
  module Drivers
    autoload :Base,           'greyscale_record/drivers/base'
    autoload :GreyscaleAPI,   'greyscale_record/drivers/greyscale_api'
    autoload :Yaml,           'greyscale_record/drivers/yaml'
  end
end