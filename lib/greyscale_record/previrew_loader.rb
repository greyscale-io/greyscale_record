module GreyscaleRecord
  class Database

    class << self

      def register( model )
        __tables[model.name] = model.driver.load!(model.name)
      end

      private

      attr_accessor :__tables
    end
  end
end