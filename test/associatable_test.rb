require 'test_helper'

class AssociatableTest < Minitest::Test
  def test_belongs_to_adds_association
    Person.belongs_to :fake
    assert_equal [:person_shoes, :favorite_shoes, :images, :fake], Person.__associations.keys
    assert_equal GreyscaleRecord::Associations::BelongsTo, Person.__associations.values.last.class
  end

  def test_belongs_to_adds_index
    refute_equal [:id], GreyscaleRecord::Base.data_store.table("sizes").send( :indices )
    Size.belongs_to :fake
    assert_equal [:id, "fake_id"], GreyscaleRecord::Base.data_store.table("sizes").send( :indices ).keys
  end

  def test_has_one_adds_association
    Person.has_one :fake
    assert_equal [:person_shoes, :favorite_shoes, :images, :fake], Person.__associations.keys
    assert_equal GreyscaleRecord::Associations::HasOne, Person.__associations.values.last.class
  end

  def test_has_many_adds_association
    Person.has_many :fake
    assert_equal [:person_shoes, :favorite_shoes, :images, :fake], Person.__associations.keys
    assert_equal GreyscaleRecord::Associations::HasMany, Person.__associations.values.last.class
  end

  def test_belongs_to_correctly_queries
    assert_equal "La Sportiva", Shoe.find( :solution ).manufacturer.name
  end

  def test_has_one_correctly_queries
    assert_equal "http://placekitten.com/300/300", Manufacturer.find( :la_sportiva ).logo.image_url
  end

  def test_has_many_correctly_queries
    assert_equal ["Solution", "Speedster"], Manufacturer.find( :la_sportiva ).shoes.map(&:name)
  end

  def test_through_correctly_queries
    assert_equal "Solution", Person.find( :abby ).favorite_shoes.name
  end

  def test_polymorphic_associaitons_work
    assert_equal ["a.jpg", "b.jpg"], Person.find( :abby ).images.map( &:image_url )
  end

  def test_polymorphic_associations_work_with_class_options
    assert_equal "banner.jpg", Manufacturer.find( :five_ten ).banner.image_url
  end

  def test_polymorphic_belongs_to_can_call_association
    assert Image.first.thing
  end

  def test_object_association_raises
    assert_raises GreyscaleRecord::Errors::AssociationError do
      Person.belongs_to :object
    end
  end

  def test_invalid_assocaition_options_raise
    assert_raises GreyscaleRecord::Errors::AssociationError do
      Person.belongs_to :thing, bad_option: :lol_fake
    end
    assert_raises GreyscaleRecord::Errors::AssociationError do
      Person.belongs_to :thing, through: :lol_fake
    end
    assert_raises GreyscaleRecord::Errors::AssociationError do
      Person.has_many :things, polymorphic: true
    end
  end

  def test_valid_association_with_no_value_does_not_raise
    assert_equal nil, Person.find( :josh ).favorite_shoes
    assert_empty Manufacturer.find( :boreal ).sizes
    assert_equal nil, Manufacturer.find( :boreal ).logo
    assert_equal nil, Logo.find( :mad_rock ).manufacturer
  end
end