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


class DeliciousBundleTest < Test::Unit::TestCase
  
  
  # =========================================================================
  # These tests check object constructor behavior 
  # =========================================================================
  
  def test_initialize
    obj = nil
    assert_nothing_raised() { obj = WWW::Delicious::Bundle.new('name') }
    assert_instance_of(WWW::Delicious::Bundle, obj)
  end
  
  def test_initialize_with_tags
    obj = nil
    assert_nothing_raised() { obj = WWW::Delicious::Bundle.new('name', []) }
    assert_instance_of(WWW::Delicious::Bundle, obj)
  end
  
  def test_initialize_raises_without_name
    assert_raise(ArgumentError) { WWW::Delicious::Bundle.new() }
  end
  
  
  # =========================================================================
  # These tests check constructor options
  # =========================================================================
    
  def test_initialize_name
    obj = nil
    name = 'test_name'
    assert_nothing_raised() { obj = instance(name) }
    assert_instance_of(WWW::Delicious::Bundle, obj)
    assert_equal(name, obj.name)
  end
    
  def test_initialize_tags
    obj = nil
    name = 'test_name'
    tags = %w(foo bar)
    assert_nothing_raised() { obj = instance(name, tags) }
    assert_instance_of(WWW::Delicious::Bundle, obj)
    assert_equal(tags, obj.tags)
  end
  
  
  def test_from_rexml
    xml = '<bundle name="music" tags="ipod mp3 music" />'
    dom = REXML::Document.new(xml)
    obj = WWW::Delicious::Bundle.from_rexml(dom.root)
    assert_instance_of(WWW::Delicious::Bundle, obj)
    assert_equal('music', obj.name)
    assert_equal(%w(ipod mp3 music), obj.tags)
  end


  protected
  #
  # Returns a valid instance of <tt>WWW::Delicious::Bundle</tt>
  # initialized with given +options+.
  #
  def instance(name, tags = [])
    return WWW::Delicious::Bundle.new(name, tags)
  end
  
  
end
