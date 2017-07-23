module GreyscaleRecord
  module Indexable
    extend ActiveSupport::Concern

    included do
      class_attribute :__indices
      self.__indices = { }

      class << self
        def index(field)
          return if GreyscaleRecord.live_reload
          data.add_index( field )
        end

        def find_in_index(field, values)
          keys = Array(data.index_for(field).find(values))
          
          keys.map do |id|
            data[id]
          end
        end

        def indexed?(field)
          data.indexed? field
        end
      end
    end
  end
end