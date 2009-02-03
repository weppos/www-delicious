# 
# = WWW::Delicious
#
# Ruby client for del.icio.us API.
# 
#
# Category::    WWW
# Package::     WWW::Delicious
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
# SVN: $Id$
#++


require 'test_helper'
require 'www/delicious/bundle'


class BundleTest < Test::Unit::TestCase
  
  def test_bundle
    expected = { :name => 'MyTag', :tags => %w(foo bar) }
    assert_attributes(instance(expected), expected)
  end
  
  def test_tag_from_rexml
    dom = REXML::Document.new(File.read(TESTCASES_PATH + '/element/bundle.xml'))
    expected = { :name => 'music', :tags => %w(ipod mp3 music) }
    
    element = WWW::Delicious::Bundle.from_rexml(dom.root)
    assert_attributes(element, expected)
  end
  
  
  def test_bundle_name_strips_whitespaces
    [' foo   ', 'foo  ', ' foo ', '  foo'].each do |v|
      assert_equal('foo', instance(:name => v).name) # => 'foo'
    end
  end
  
  def test_to_s_returns_name_as_string
    assert_equal('foobar', instance(:name => 'foobar', :tags => %w(foo bar)).to_s)
  end
  
  def test_to_s_returns_empty_string_with_name_nil
    assert_equal('', instance(:name => nil).to_s)
  end
  
  
  # def test_valid
  # end
  
  
  protected
  
    # returns a stub instance
    def instance(values = {}, &block)
      WWW::Delicious::Bundle.new(values)
    end

end
