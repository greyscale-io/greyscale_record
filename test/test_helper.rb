$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start

require 'greyscale_record'

GreyscaleRecord.logger = Logger.new('/dev/null')
GreyscaleRecord::Drivers::Yaml.root = File.expand_path("./db/fixtures", File.dirname(__FILE__))
GreyscaleRecord::Base.driver = GreyscaleRecord::Drivers::Yaml

class TestLogger
  def initialize(action)
    @action = action
  end
  [:fatal, :error, :warn, :info, :debug].each do |severity|
    define_method severity do |message, &block|
      send @action, message
    end
  end
end

class Person < GreyscaleRecord::Base
  property :not_in_yaml, :lol
  has_many :person_shoes
  has_one :favorite_shoes, through: :person_shoes, class_name: "Shoe"

  has_many :images, as: :thing
end

class PersonShoe < GreyscaleRecord::Base
  belongs_to :person
  belongs_to :shoe
end

class Fake < GreyscaleRecord::Base
end

class Logo < GreyscaleRecord::Base
  belongs_to :manufacturer
end

class ManufacturerSize < GreyscaleRecord::Base
  belongs_to :manufacturers
  belongs_to :sizes
end

class Manufacturer < GreyscaleRecord::Base
  has_many :shoes
  has_one  :logo
  has_many :manufacturer_sizes
  has_many :sizes, through: :manufacturer_sizes

  has_one :banner, as: :thing, class_name: "Image"
end

class Shoe < GreyscaleRecord::Base
  belongs_to :manufacturer
end

class Size < GreyscaleRecord::Base
end

class Image < GreyscaleRecord::Base
  belongs_to :thing, polymorphic: true
end

require 'minitest/autorun'
