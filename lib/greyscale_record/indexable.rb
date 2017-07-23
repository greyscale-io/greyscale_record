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
      end
    end
  end
end