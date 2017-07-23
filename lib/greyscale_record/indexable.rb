module GreyscaleRecord
  module Indexable
    extend ActiveSupport::Concern

    included do
      class << self
        # DEPRICATED
        # TODO: remove
        def index(field)
          return if GreyscaleRecord.live_reload
          table.add_index( field )
        end
      end
    end
  end
end