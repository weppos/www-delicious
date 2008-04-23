# 
# = WWW::Delicious
#
# Ruby client for del.icio.us API.
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id$
#++


require File.dirname(__FILE__) + '/../helper'
require 'www/delicious/tag'


class DeliciousTagTest < Test::Unit::TestCase
  
  
  # =========================================================================
  # These tests check object constructor behavior 
  # =========================================================================
  
  def test_initialize
    assert_nothing_raised() do
      obj = WWW::Delicious::Tag.new(:name => 'name')
      assert_instance_of(WWW::Delicious::Tag, obj)
    end
  end
  
  def test_initialize_with_block
    assert_nothing_raised() do 
      obj = WWW::Delicious::Tag.new(:name => 'name') do |tag|
        assert_instance_of(WWW::Delicious::Tag, tag)
      end
      assert_instance_of(WWW::Delicious::Tag, obj)
    end
  end
  
  def test_initialize_raises_without_values
    assert_raise(ArgumentError) do
      obj = WWW::Delicious::Tag.new()
    end
  end
  
  def test_initialize_raises_without_values_hash_or_rexml
    exception = assert_raise(ArgumentError) do
      obj = WWW::Delicious::Tag.new('foo')
    end
    assert_match(/`hash` or `REXML::Element`/i, exception.message)
  end
  
  
  # =========================================================================
  # These tests check constructor options
  # =========================================================================
    
  def test_initialize_values_kind_of_hash
    name = 'test'; count = 20
    assert_nothing_raised() do 
      obj = instance(:name => name, :count => count) do |t|
        assert_instance_of(WWW::Delicious::Tag, t)
        assert_equal(name, t.name)
        assert_equal(count, t.count)
      end
    end
  end

  def test_initialize_values_kind_of_rexml
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
  
  def test_api_valid
    ['foo', ' foo '].each do |v|
      assert(instance(v).api_valid?)
    end
    ['', '  '].each do |v|
      assert(!instance(v).api_valid?)
    end
  end


  protected
  #
  # Returns a valid instance of <tt>WWW::Delicious::Tag</tt>
  # initialized with given +options+.
  #
  def instance(args, &block)
    values = case args
    when Hash
      args
    else
      { :name => args.to_s() }
    end
    return WWW::Delicious::Tag.new(values, &block)
  end
  
  
end
