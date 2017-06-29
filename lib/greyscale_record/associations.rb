module GreyscaleRecord
  module Associations
    autoload :Base,       'greyscale_record/associations/base'
    autoload :BelongsTo,  'greyscale_record/associations/belongs_to'
    autoload :Hasable,    'greyscale_record/associations/hasable'
    autoload :HasMany,    'greyscale_record/associations/has_many'
    autoload :HasOne,     'greyscale_record/associations/has_one'
  end
end