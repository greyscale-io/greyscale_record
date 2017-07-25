module GreyscaleRecord
  module Indexable
    extend ActiveSupport::Concern

    included do
      class << self
        # DEPRICATED
        # TODO: remove
        def index(field)
          return if GreyscaleRecord.live_reload
          data_store.add_index( name, field )
        end
      end
    end
  end
end