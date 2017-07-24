module GreyscaleRecord
  module Cacheable
    extend ActiveSupport::Concern

    included do
      class << self
        def cache_key
          @cache_key ||= Digest::SHA256.hexdigest(table.to_json)
        end
      end

      def cache_key
        @cache_key ||= Digest::SHA256.hexdigest(@attributes.to_json)
      end
    end
  end
end