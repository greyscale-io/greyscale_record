module GreyscaleRecord
  module DataStore
    class Store
      def initialize
        @data = {}
        @tables = {}
      end

      def []( name )
        data[ name ]
      end

      def table( name )
        unless @tables[name]
          raise GreyscaleRecord::Errors::DataStoreError, "Data Store error: table '#{name}' does not exist"
        end

        @tables[name]
      end

      def init_table( name, rows )
        @data[name] = rows
        @tables[name] = Table.new( name, self )
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
        Thread.current[patch_key] = patched_data patch
      end

      def remove_patch
        Thread.current[patch_key] = nil
      end

      def patched?
        Thread.current[patch_key].present?
      end
      
      private

      def patched_data(patch)
        unless patch.respond_to? :apply
          raise GreyscaleRecord::Errors::DataStoreError, "Data Store Error: apply_patch: patch must respond to 'apply(doc)'."
        end

        patch.apply( @data.deep_dup )
      end

      def patch_key
        @key ||= "#{object_id}_patch"
      end


      def data
        if patched?
          Thread.current[patch_key]
        else
          @data
        end
      end
    end
  end
end