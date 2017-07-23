require 'test_helper'

class IndexableTest < Minitest::Test
  def setup 
    Person.load!
    Person.index(:name)
    refute_empty Person.send( :data ).send( :indices )
  end

  def teardown
    Person.load!
  end

  def test_can_add_index
    Person.index(:name)
    refute_empty Person.send( :data ).send( :indices )
    assert_equal [:id, :name], Person.send( :data ).send( :indices ).keys
  end

  def test_index_silinces_find_by_warnings
    logger = GreyscaleRecord.logger
    GreyscaleRecord.logger = TestLogger.new :raise
    assert Person.find_by( name: "Josh Dreher" )
    GreyscaleRecord.logger = logger
  end

  def test_complex_find_by_indexed_queries
    Person.index(:url_slug)
    logger = GreyscaleRecord.logger
    GreyscaleRecord.logger = TestLogger.new :raise
    assert Person.find_by( name: "Josh Dreher", url_slug: 'josh-dreher' )
    GreyscaleRecord.logger = logger
  end
end