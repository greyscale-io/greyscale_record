module GreyscaleRecord
  module DataStore
    class Table
      attr_accessor :name

      def initialize(name, store)
        @name = name
        @store = store

        # initialize the index array for later use
        @indices = {}

        # generate IDs for the records based on YAML keys
        generate_ids!

        # preemptively index the IDs
        add_index :id
      end

      def all
        rows.values
      end

      def add_index( column )
        return if @store.patched?
        @indices = @indices.merge( { column => Index.new(column, rows) } )
      end

      def find( params = {} )
        return all if params.empty?
        sets = params.map do | column, values |
          if !patched? && indexed?( column )
            find_in_index column, values
          else
            GreyscaleRecord.logger.warn "You are running a query on #{@name}.#{column} which is not indexed. This will perform a table scan."
            find_in_column column, values
          end
        end

        sets.inject( sets.first ) do |result, subset|
          result & subset
        end
      end

      private

      def rows
        @store[@name]
      end

      def patched?
        @store.patched?
      end

      def indexed?(column)
        @indices[column].present?
      end

      def find_in_column( column, values )
        rows.values.select do |datum|
          Array( values ).include? datum[ column ]
        end
      end

      def find_in_index( column, values )
        keys = @indices[column].find( Array( values ) )
        
        keys.map do |id|
          rows[id]
        end
      end

      def generate_ids!
        # init IDs
        rows.each do |k, v|
          v[:id] = k
        end
      end
    end
  end
end
