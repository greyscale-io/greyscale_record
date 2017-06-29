module GreyscaleRecord
  module Errors
    class RecordNotFound < StandardError
    end

    class AssociationError < StandardError
    end

    class InvalidFieldError < StandardError
    end

    class DriverError < StandardError
    end
  end
end