require 'test_helper'
require 'www/delicious/post'


class PostTest < Test::Unit::TestCase
  
  def test_post
    expected = { :title => 'JavaScript DOM reference', :url => URI.parse('http://www.howtocreate.co.uk/tutorials/texterise.php?dom=1') }
    assert_attributes(instance(expected), expected)
  end
  
  def test_post_shared_defaults_to_true
    assert(instance(:title => 'Foo').shared)
  end
  
  def test_post_shared_is_false
    assert(!instance(:title => 'Foo', :shared => false).shared)
  end
  
  def test_post_from_rexml
    dom = REXML::Document.new(File.read(TESTCASES_PATH + '/element/post.xml'))
    element = WWW::Delicious::Post.from_rexml(dom.root)

    assert_equal(URI.parse('http://www.howtocreate.co.uk/tutorials/texterise.php?dom=1'), element.url)
    assert_equal("JavaScript DOM reference", element.title)
    assert_equal("dom reference", element.notes)
    assert_equal("c0238dc0c44f07daedd9a1fd9bbdeebd", element.uid)
    assert_equal(55, element.others)
    assert_equal(%w(dom javascript webdev), element.tags)
    assert_equal(Time.parse("2005-11-28T05:26:09Z"), element.time)
  end
  
  def test_post_from_rexml_not_shared
    dom = REXML::Document.new(File.read(TESTCASES_PATH + '/element/post_unshared.xml'))
    element = WWW::Delicious::Post.from_rexml(dom.root)

    assert(!element.shared)
  end
  
  
  # def test_valid
  # end
  
  
  protected
  
    # returns a stub instance
    def instance(values = {}, &block)
      WWW::Delicious::Post.new(values)
    end
  
end
