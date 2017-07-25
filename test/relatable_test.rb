require 'test_helper'

class RelatableTest < Minitest::Test
  def test_chaining_wheres
    assert_equal Person, Person.where( url_slug: "josh-dreher" ).and( id: "josh" ).first.class
    assert_empty Person.where( id: "fake" ).and( name: "Fake" )
    assert_equal "Josh Dreher", Person.where( id: "josh" ).where( url_slug: "josh-dreher", name: "Josh Dreher" ).first.name
  end

  def test_associations_can_be_related
    assert_equal "a.jpg", Person.find( :abby ).images.where( image_url: "a.jpg" ).first.image_url
    assert_empty Person.find( :abby ).images.where( image_url: "lol" )
  end
end