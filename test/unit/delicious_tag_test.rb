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
require 'www/delicious/bundle'


class DeliciousTagTest < Test::Unit::TestCase
  
  
  # =========================================================================
  # These tests check object constructor behavior 
  # =========================================================================
  
  def test_initialize
    assert_nothing_raised() do
      obj = WWW::Delicious::Tag.new('name')
      assert_instance_of(WWW::Delicious::Tag, obj)
    end
  end
  
  def test_initialize_with_block
    assert_nothing_raised() do 
      obj = WWW::Delicious::Tag.new('name') do |tag|
        assert_instance_of(WWW::Delicious::Tag, tag)
      end
      assert_instance_of(WWW::Delicious::Tag, obj)
    end
  end
  
  def test_initialize_raises_without_name
    assert_raise(ArgumentError) { WWW::Delicious::Tag.new() }
  end
  
  
  # =========================================================================
  # These tests check constructor options
  # =========================================================================
    
  def test_initialize_name
    obj = nil
    name = 'test_name'
    assert_nothing_raised() { obj = instance(name) }
    assert_instance_of(WWW::Delicious::Tag, obj)
    assert_equal(name, obj.name)
  end


  def test_initialize_name_kind_of_rexml
    xml = '<tag count="1" tag="activedesktop" />'
    dom = REXML::Document.new(xml)
    obj = WWW::Delicious::Tag.new(dom.root)
    assert_instance_of(WWW::Delicious::Tag, obj)
    assert_equal('activedesktop', obj.name)
    assert_equal(1, obj.count)
  end


  protected
  #
  # Returns a valid instance of <tt>WWW::Delicious::Tag</tt>
  # initialized with given +options+.
  #
  def instance(name, &block)
    return WWW::Delicious::Tag.new(name, &block)
  end
  
  
end
