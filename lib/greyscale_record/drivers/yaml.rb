module GreyscaleRecord
  module Drivers
    class Yaml < Base

      private 

      def load_data( object )
        YAML.load_file( data_file( object ) ).with_indifferent_access
      end

      def data_file( object )
        [root, "#{object}.yml"].compact.join("/")
      end
    end
  end
end
