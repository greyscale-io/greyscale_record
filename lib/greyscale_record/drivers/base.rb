module GreyscaleRecord
  module Drivers
    class Base

      attr_reader :root

      def initialize( root )
        @root = root
      end
      
      def load!(object)

        raise GreyscaleRecord::Errors::DriverError, "driver needs to define a `root`" unless root
        
        data = load_data(object)
        
        GreyscaleRecord.logger.info "#{object} successfully loaded data"

        data

      rescue => e
        GreyscaleRecord.logger.error "#{self.class} failed to load data for #{object}: #{e}`"
        {}
      end

      private 

      def load_data
        raise NotImplementedError, "load_data is not implemented"
      end
    end
  end
end
