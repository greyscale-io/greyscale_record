module GreyscaleRecord
  module DataStore
    class Table
      attr_reader :rows
      delegate :each, :values, to: :rows

      def initialize(rows)
        @rows = rows

        @indices = {}

        generate_ids!

        add_index :id
      end

      def [](key)
        @rows[key]
      end

      def add_index( column, options = {} )
        @indices = @indices.merge( { column => Index.new(column, @rows) } )
      end

      def read( params )

      end

      def indexed?(column)
        @indices[column].present?
      end

      def find_in_index(column, values)
        keys = Array(index_for(column).find(values))
        
        keys.map do |id|
          @rows[id]
        end
      end

      private

      attr_accessor :indices

      def generate_ids!
        # init IDs
        @rows.each do |k, v|
          v[:id] = k
        end
      end

      def index_for(column)
        @indices[column]
      end
    end
  end
end
