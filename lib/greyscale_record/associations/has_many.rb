module GreyscaleRecord
  module Associations
    class HasMany < Base
      include Hasable

      def action
        :where
      end
    end
  end
end
