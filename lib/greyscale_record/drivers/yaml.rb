module GreyscaleRecord
  module Drivers
    class Yaml < Base

      class << self

        private 

        def load_data( class_name )
          YAML.load_file( data_file( class_name ) ).with_indifferent_access
        end

        def data_file( class_name )
          [root, "#{class_name}.yml"].compact.join("/")
        end
      end
    end
  end
end
