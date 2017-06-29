module GreyscaleRecord
  class Base
    include ActiveModel::Model
    include Associatable
    include Cacheable
    include Propertiable
    include Indexable
    include Instanceable
    include Queriable

    class_attribute :data
    class_attribute :driver

    class << self

      def load!
        @data = driver.load!(_class_name)
        return unless @data
        
        # let's preemptively index by id so that when we do a find_by id:, or a where id: it won't table scan
        idify_data!
        
        index :id unless GreyscaleRecord.live_reload
      end

      def inherited(subclass)
        subclass.load!
      end

      protected

      def _class_name
        self.name.pluralize.downcase
      end

      def idify_data!
        @data.each do |k, v|
          v[:id] = k
        end
      end

      def data
        load! if GreyscaleRecord.live_reload
        @data
      end
    end
  end
end
