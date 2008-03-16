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
require 'www/delicious/tag'


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
    assert_equal(0, obj.count)
  end

  def test_initialize_name_kind_of_rexml
    xml = '<tag count="1" tag="activedesktop" />'
    dom = REXML::Document.new(xml)
    obj = WWW::Delicious::Tag.new(dom.root)
    assert_instance_of(WWW::Delicious::Tag, obj)
    assert_equal('activedesktop', obj.name)
    assert_equal(1, obj.count)
  end

  
  def test_name_setter_getter
    instance('foo') do |tag|
      assert_equal('foo', tag.name)
      tag.name = 12
      assert_equal('12', tag.name)
      tag.name = :foo
      assert_equal('foo', tag.name)
    end
  end

  def test_name_strip_whitespaces
    [' foo   ', 'foo  ', ' foo ', '  foo'].each do |v|
      assert_equal(v.strip, instance(v).name) # => 'foo'
    end
  end

  def test_count_setter_getter
    instance('foo') do |tag|
      assert_equal(0, tag.count)
      tag.count = 12
      assert_equal(12, tag.count)
      tag.count = '23'
      assert_equal(23, tag.count)
    end
  end
  
  def test_to_s
    instance('foobar') do |tag|
      assert_equal('foobar', tag.to_s)
    end
  end
  
  def test_valid
    ['foo', ' foo '].each do |v|
      assert(instance(v).valid?)
    end
    ['', '  '].each do |v|
      assert(!instance(v).valid?)
    end
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
