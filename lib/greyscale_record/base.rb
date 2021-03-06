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
        data_store.add_table table_name
      end

      def inherited(subclass)
        subclass.load!
      end

      def table_name
        self.to_s.pluralize.downcase
      end
    end
  end
end
