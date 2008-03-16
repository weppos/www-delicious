# 
# = WWW::Delicious
#
# Web service library for del.icio.us API
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id: delicious_test.rb 13 2008-03-15 13:03:13Z weppos $
#++


require File.dirname(__FILE__) + '/../helper'


if TEST_REAL_TESTS
  puts "*WARNING* Running real online tests with account #{ENV['DUSERNAME']} => #{ENV['DPASSWORD']}."
else
  puts "Real online tests skipped. Set 'DUSERNAME' and 'DPASSWORD' env variables to run them."
end


class DeliciousOnlineTest < Test::Unit::TestCase
  include WWW::Delicious::TestCase
  
  def test_valid_account
    obj = instance(:username => 'foo', :password => 'bar')
    assert(!obj.valid_account?)
  end
  
  def test_update
    result = nil
    assert_nothing_raised() { result = instance.update() }
    assert_not_nil(result)
  end
  
  def test_bundles_all
    result = nil
    assert_nothing_raised() { result = instance.bundles_all() }
    assert_not_nil(result)
    result.each do |bundle|
      assert_instance_of(WWW::Delicious::Bundle, bundle)
      assert_not_nil(bundle.name)
      assert_instance_of(Array, bundle.tags)
    end
  end
  
  def test_bundles_set
    bundle = WWW::Delicious::Bundle.new('test_bundle', %w(ruby python).sort)
    obj = instance()
    
    # create the bundle
    assert_nothing_raised() { obj.bundles_set(bundle) }
    # search for the bundle
    #assert_not_nil(search_for_bundle(bundle, obj))
  end
  
  def test_bundles_delete
    bundle = WWW::Delicious::Bundle.new('test_bundle', %w(ruby python).sort)
    obj = instance()
    
    # search for the bundle
    #assert_not_nil(search_for_bundle(bundle, obj))
    # delete the bundle
    assert_nothing_raised() { obj.bundles_delete(bundle) }
    # search for the bundle again
    #assert_nil(search_for_bundle(bundle, obj))
  end
  
  def test_tags_get
    result = nil
    assert_nothing_raised() { result = instance.tags_get() }
    assert_not_nil(result)
    result.each do |tag|
      assert_instance_of(WWW::Delicious::Tag, tag)
      assert_not_nil(tag.name)
      assert_not_nil(tag.count)
    end
  end
  
  def test_tags_rename
    ftag = WWW::Delicious::Tag.new('old_tag')
    otag = WWW::Delicious::Tag.new('new_tag')
    obj = instance()
    
    assert_nothing_raised() { obj.tags_rename(ftag, otag) }
  end
  
  def test_posts_get
    obj = instance()
    results = nil
    assert_nothing_raised() { results = obj.posts_get() }
    
    assert_kind_of(Array, results)
    results.each do |post|
      assert_kind_of(WWW::Delicious::Post, result)
    end
  end

  
  protected
  def search_for_bundle(bundle, obj)
    bundles = obj.bundles_all()
    return bundles.detect { |b| b.name == bundle.name && b.tags.sort == bundle.tags }
  end

end if TEST_REAL_TESTS
