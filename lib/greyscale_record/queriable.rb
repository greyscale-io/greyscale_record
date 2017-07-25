module GreyscaleRecord
  module Queriable
    extend ActiveSupport::Concern

    included do
      class << self
        def find(id)
          records = where( id: id.to_s )
          raise Errors::RecordNotFound, "#{ self }: Record not found: #{ id }" if records.empty?
          records.first
        end

        def find_by( params = { } )
          results = where params
          raise Errors::RecordNotFound, "#{ self }: Could not find record that matches: #{ params.inspect }" if results.empty?
          results.first
        end

        def all
          where
        end

        def first
          all.first
        end

        # TODO: move this into scopes
        def where( params = {} )
          # results = table.find params
          # results = data_store.find params.merge _table: name

          # results.map do | result |
          #   new result
          # end

          Relation.new self, params 
        end
      end
    end
  end
end