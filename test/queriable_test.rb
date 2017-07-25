require 'test_helper'

class QueriableTest < Minitest::Test
  def test_can_find_by_id
    assert Person.find :josh
    assert Person.find "josh"
  end

  def test_can_find_by_any_field
    assert Person.find_by( url_slug: "josh-dreher" )
  end

  def test_can_find_by_many_fields
    assert Person.find_by( url_slug: "josh-dreher", name: "Josh Dreher" )
  end

  def test_find_and_find_by_return_an_object
    assert_equal Person, Person.find( :josh ).class
    assert_equal Person, Person.find_by( url_slug: "josh-dreher" ).class
  end

  def test_unindexed_find_by_warns
    logger = GreyscaleRecord.logger
    GreyscaleRecord.logger = TestLogger.new :print
    assert_output "You are running a query on people.url_slug which is not indexed. This will perform a table scan." do
      assert Person.find_by( url_slug: "josh-dreher" )
    end
    GreyscaleRecord.logger = logger
  end

  def test_all
    ids = Person.all.map(&:id)
    assert_equal ["greg", "abby", "josh", "teal"], ids
  end

  def test_find_miss_raises
    assert_raises GreyscaleRecord::Errors::RecordNotFound, "Record not found: lolwat" do
      Person.find :lolwat
    end
  end

  def test_find_by_miss_raises
    params = { id: :lolwat }
    assert_raises "Could not find record that matches: #{params.inspect}" do
      Person.find_by params
    end
  end
end