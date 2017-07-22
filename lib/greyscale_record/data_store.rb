module GreyscaleRecord
  module DataStore
    class Engine

      # A data store can only have one driver. 
      # It's like a database connection. If you want models to connect to different
      #   databases, you have them inherit from different base classes that specify 
      #   a db to connect to.

      # Pros:
      #   * All the data in your store comes from the same place. Easy to reason about
      #   * No chance of data source collisions. Can't populate tables from multiple sources
      #   * Cleaner table-adding interface 
      #       store.add_table( name )
      #            vs
      #       store.add_table( name, driver )
      #       # where does driver get initialized? 
      #   * Straight forward patching: one complete patch at a time
      #       How do you patch across differntly driven tables?
      #       Do you need a patch stack?
      #   * Depending on how your remote is built, you can pull in all the data at once
      #
      # Cons:
      #   * Limiting if you want to have some tables come from YAML and some from remote
      #
      # Yeah. OK.

      attr_reader :store
      delegate :apply_patch, :remove_patch, :with_patch, to: :store 

      def initialize( driver )
        @driver = driver
        @store  = Store.new
      end

      # Read only store. No writes allowed. 

      def read( options = {} )
        if GreyscaleRecord.live_reload
          load_table!( name )
        end

        # TODO: this is where all the meat is
        store[options[:table_name]]
      end

      def add_table( name )
        load_table! name
      end

      def add_index( table_name, column_name, options = {} )
        store[table_name].add_index( column_name, options)
      end

      private

      def store
        @store
      end

      def table(table_name)
        unless data[table_name]
          raise DataStoreError, "Data Store error: table '#{table_name}' does not exist"
        end

        data[table_name]
      end

      def load_table!( name )
        data[name] = @driver.load!( name )
        # init IDs
        data[name].each do |k, v|
          v[:id] = k
        end
      end

      def patched?
        !!Thread.current[:patched_data].present?
      end
    end

    class Store
      def initialize( data )
        @data = data
        @tables = {}
      end

      def []( table_name )
        @data[table_name]
      end

      def []=( table_name, data )
        @data[table_name] = data
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

    class Table
      def initialize(rows)
        @rows = rows

        @indices = {}

        generate_ids!
      end

      def [](key)
        @rows[key]
      end

      def add_index( column, options = {} )
        @indices = @indices.merge( { column => Index.new(column, @rows) } )
      end

      private

      def generate_ids
        # init IDs
        @rows.each do |k, v|
          v[:id] = k
        end
      end
    end
  end
end
