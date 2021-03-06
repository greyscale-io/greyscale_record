module GreyscaleRecord
  class Relation

    delegate :present?, :empty?, :==, to: :all

    def initialize( base, params )
      @base   = base
      @params = params.dup.merge!( _table: @base.table_name )
    end

    def where( params )
      self.class.new @base, @params.merge( params )
    end

    def and( params )
      self.class.new @base, @params.merge( params )
    end

    def all
      @all ||= @base.data_store.find( @params.dup ).map do | result |
        @base.new result
      end
    end

    def method_missing( method, *args, &block )
      all.send method, *args, &block
    end
  end
end