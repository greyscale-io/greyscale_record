require 'test_helper'
require 'hana'

class EngineTest < Minitest::Test
  def setup
    @patch = ::Hana::Patch.new [ { 'op' => 'add', 'path' => '/people/mike', 'value' => { id: "mike", name: "Mike Uchman", url_slug: "mike-uchman", title: "chief balling officer" } } ]
  end

  def test_can_apply_patch
    GreyscaleRecord::Base.data_store.apply_patch @patch

    assert_equal "Mike Uchman", Person.find( 'mike' ).name
    assert_equal "Mike Uchman", Person.where( id: 'mike' ).first.name

    GreyscaleRecord::Base.data_store.remove_patch

    refute GreyscaleRecord::Base.data_store.send( :store ).patched?
    
    assert_empty Person.where( id: "mike" )

    refute Person.all.map(&:id).include? "mike"

  end

  def test_can_apply_patch_in_block
    GreyscaleRecord::Base.data_store.with_patch @patch do

      assert_equal "Mike Uchman", Person.find( 'mike' ).name
      assert_equal "Mike Uchman", Person.where( id: 'mike' ).first.name

    end

    refute GreyscaleRecord::Base.data_store.send( :store ).patched?
    
    assert_empty Person.where( id: "mike" )

    refute Person.all.map(&:id).include? "mike"
  end

  def test_patch_application_is_thread_safe
    Thread.new do
      GreyscaleRecord::Base.data_store.apply_patch @patch

      assert_equal "Mike Uchman", Person.find( 'mike' ).name
      assert_equal "Mike Uchman", Person.where( id: 'mike' ).first.name

      sleep 5
    end
    sleep 1

    assert_empty Person.where( id: "mike" )

    refute Person.all.map(&:id).include? "mike"
  end

end