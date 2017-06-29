module GreyscaleRecord
  module Drivers
    class Base

      class_attribute :root
      
      class << self
        def load!(class_name)

          raise GreyscaleRecord::DriverError "driver needs to define a `root`" unless root
          
          data = load_data(class_name)
          
          GreyscaleRecord.logger.info "#{class_name} successfully loaded data"

          data

        rescue => e
          GreyscaleRecord.logger.error "#{self} failed to load data for #{class_name}: #{e}"
          return nil
        end

        private 

        def load_data
          raise NotImplementedError "load_data is not implemented"
        end
      end
    end
  end
end
