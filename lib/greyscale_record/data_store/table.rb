module GreyscaleRecord
  module DataStore
    class Table

      def initialize(name, rows)
        @name = name
        @rows = rows.with_indifferent_access

        # initialize the index array for later use
        @indices = {}

        # generate IDs for the records based on YAML keys
        generate_ids!

        # preemptively index the IDs
        add_index :id
      end

      def all
        @rows.values
      end

      def first
        @rows.values.first
      end

      def add_index( column )
        @indices = @indices.merge( { column => Index.new(column, @rows) } )
      end

      def find( params )
        if all_indexed?(params.keys)
          find_by_indexed(params)
        else
          find_by_scan(params)
        end
      end

      private

      attr_accessor :indices
      
      private

      def find_by_scan(params)
        @rows.values.select do |datum|
          params.all? do |param, expected_value|
            val = Array(expected_value).include? datum[param]
          end
        end
      end

      def find_by_indexed(params)
        sets = []
        params.each do |index, values|
          sets << find_in_index(index, Array(values))
        end

        # find the intersection of all the sets
        sets.inject( sets.first ) do |result, subset|
          result & subset
        end
      end

      def all_indexed?(fields)
        fields.all? do |field|
          indexed = indexed? field
          unless indexed
            GreyscaleRecord.logger.warn "You are running a query on #{@name}.#{field} which is not indexed. This will perform a table scan."
          end
          indexed
        end
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
