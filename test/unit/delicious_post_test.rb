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
# SVN: $Id: delicious_test.rb 14 2008-03-15 20:38:28Z weppos $
#++


require File.dirname(__FILE__) + '/../helper'
require 'www/delicious/post'


class DeliciousPostTest < Test::Unit::TestCase
  
  
  # =========================================================================
  # These tests check object constructor behavior 
  # =========================================================================
  
  def test_initialize
    assert_nothing_raised() do
      obj = WWW::Delicious::Post.new(:url => 'http://localhost', :title => 'foo')
      assert_instance_of(WWW::Delicious::Post, obj)
    end
  end
  
  def test_initialize_with_block
    assert_nothing_raised() do 
      obj = WWW::Delicious::Post.new(:url => 'http://localhost', :title => 'foo') do |tag|
        assert_instance_of(WWW::Delicious::Post, tag)
      end
      assert_instance_of(WWW::Delicious::Post, obj)
    end
  end
  
  def test_initialize_raises_without_values
    assert_raise(ArgumentError) do
      obj = WWW::Delicious::Post.new()
    end
  end
  
  def test_initialize_raises_without_values_hash_or_rexml
    exception = assert_raise(ArgumentError) do
      obj = WWW::Delicious::Post.new('foo')
    end
    assert_match(/`hash` or `REXML::Element`/i, exception.message)
  end
  
  
  # =========================================================================
  # These tests check constructor options
  # =========================================================================
    
  def test_initialize_values_kind_of_hash
  end


  def test_initialize_values_kind_of_rexml
    xml = <<-EOS
<post href="http://www.howtocreate.co.uk/tutorials/texterise.php?dom=1" 
  description="JavaScript DOM reference" 
  extended="dom reference" 
  hash="c0238dc0c44f07daedd9a1fd9bbdeebd" 
  others="55" tag="dom javascript webdev" time="2005-11-28T05:26:09Z" />
EOS
    dom = REXML::Document.new(xml)
    obj = WWW::Delicious::Post.new(dom.root)
    assert_instance_of(WWW::Delicious::Post, obj)
    # check all attrs
    assert_equal(URI.parse('http://www.howtocreate.co.uk/tutorials/texterise.php?dom=1'), obj.url)
    assert_equal("JavaScript DOM reference", obj.title)
    assert_equal("dom reference", obj.notes)
    assert_equal("c0238dc0c44f07daedd9a1fd9bbdeebd", obj.uid)
    assert_equal(55, obj.others)
    assert_equal(%w(dom javascript webdev), obj.tags)
    assert_equal(Time.parse("2005-11-28T05:26:09Z"), obj.time)
  end


  protected
  #
  # Returns a valid instance of <tt>WWW::Delicious::Tag</tt>
  # initialized with given +options+.
  #
  def instance(values, &block)
    return WWW::Delicious::Post.new(values, &block)
  end
  
  
end
