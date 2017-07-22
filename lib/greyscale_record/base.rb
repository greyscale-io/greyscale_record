module GreyscaleRecord
  class Base
    include ActiveModel::Model
    include Associatable
    include Cacheable
    include Propertiable
    include Indexable
    include Instanceable
    include Queriable

    class_attribute :data_store

    class << self

      def load!
        data_store.add_table name

        index :id unless GreyscaleRecord.live_reload
      end

      def inherited(subclass)
        subclass.load!
      end

      def name
        self.to_s.pluralize.downcase
      end

      protected

      def data
        data_store.read( table_name: name )
      end
    end
  end
end
