module GreyscaleRecord
  module DataStore
    class Store
      def initialize
        @data = {}
        @tables = {}
      end

      def []( table_name )
        unless @tables[table_name]
          raise DataStoreError, "Data Store error: table '#{table_name}' does not exist"
        end

        @tables[table_name]
      end

      def []=( table_name, data )
        @data[table_name] = data
        @tables[table_name] = Table.new(data)
      end

      def with_patch( patch )
        apply_patch patch
        yield
        remove_patch
      end

      # This only allows for one patch at a time. 
      # Is there ever a case when we would need, like a stack of these things? 
      # I don't think so? 

      def apply_patch( patch )
        Tread.current[:patched_data] = patched_data patch
      end

      def remove_patch
        Tread.current[:patched_data] = nil
      end

      private

      def patched_data(patch)
        unless patch.respond_to? :apply
          raise DataStoreError, "Data Store Error: apply_patch: patch must respond to 'apply(doc)'."
        end

        patch.apply @data
      end
    end
  end
end