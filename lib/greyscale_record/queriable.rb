module GreyscaleRecord
  module Queriable
    extend ActiveSupport::Concern

    included do
      class << self
        def find(id)
          record = table[id]
          raise Errors::RecordNotFound, "#{self}: Record not found: #{id}" unless record
          new record
        end

        def find_by(params = {})
          results = where params
          raise Errors::RecordNotFound, "#{self}: Could not find record that matches: #{params.inspect}" if results.empty?
          results.first
        end

        def all
          table.values.map do |obj|
            new obj
          end
        end

        def first
          new table.values.first
        end

        # TODO: move this into scopes
        def where(params)
          results = table.find params 

          results.map do |result|
            new result
          end
        end
      end
    end
  end
end