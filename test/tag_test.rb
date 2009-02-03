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
require 'www/delicious/tag'


class TagTest < Test::Unit::TestCase
  
  def test_tag
    expected = { :name => 'MyTag', :count => 2 }
    assert_attributes(instance(expected), expected)
  end
  
  def test_tag_from_rexml
    dom = REXML::Document.new(File.read(TESTCASES_PATH + '/element/tag.xml'))
    expected = { :count => 1, :name => 'activedesktop' }
    
    element = WWW::Delicious::Tag.from_rexml(dom.root)
    assert_attributes(element, expected)
  end
  
  
  def test_tag_name_strips_whitespaces
    [' foo   ', 'foo  ', ' foo ', '  foo'].each do |v|
      assert_equal('foo', instance(:name => v).name) # => 'foo'
    end
  end
  
  def test_to_s_returns_name_as_string
    assert_equal('foobar', instance(:name => 'foobar', :count => 4).to_s)
  end
  
  def test_to_s_returns_empty_string_with_name_nil
    assert_equal('', instance(:name => nil).to_s)
  end
  
  
  # def test_api_valid
  #   ['foo', ' foo '].each do |v|
  #     assert(instance(v).api_valid?)
  #   end
  #   ['', '  '].each do |v|
  #     assert(!instance(v).api_valid?)
  #   end
  # end
  
  
  protected
  
    # returns a stub instance
    def instance(values = {}, &block)
      WWW::Delicious::Tag.new(values)
    end

end
