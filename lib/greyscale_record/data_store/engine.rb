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

      def find( options = {} )
        table = store[options.delete(:_table)]
        if GreyscaleRecord.live_reload
          load_table!( table )
        end

        # TODO: this is where all the meat is
        table.find options
      end

      def table( name )
        store[name]
      end

      def add_table( name )
        load_table! name
      end

      def add_index( table_name, column_name )
        store[table_name].add_index( column_name )
      end

      private

      def store
        @store
      end

      def load_table!( name )
        store[name] = @driver.load!( name )
      end
    end
  end
end
