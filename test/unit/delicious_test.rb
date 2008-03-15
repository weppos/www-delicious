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
# SVN: $Id$
#++


require File.dirname(__FILE__) + '/../helper'


class DeliciousTest < Test::Unit::TestCase
  TEST_USERNAME = 'username'
  TEST_PASSWORD = 'password'

  def setup
    @default_username = TEST_USERNAME
    @default_password = TEST_USERNAME
  end
  
  
  # =========================================================================
  # These tests check object constructor behavior 
  # =========================================================================
  
  def test_initialize
    obj = nil
    assert_nothing_raised() { obj = WWW::Delicious.new(TEST_USERNAME, TEST_PASSWORD) }
    assert_instance_of(WWW::Delicious, obj)
  end
  
  def test_initialize_with_block
    obj = instance do |delicious|
      assert_instance_of(WWW::Delicious, delicious)
    end
    assert_instance_of(WWW::Delicious, obj)
  end
  
  def test_initialize_with_options
    obj = nil
    assert_nothing_raised() { obj = WWW::Delicious.new(TEST_USERNAME, TEST_PASSWORD, {:user_agent => 'ruby/test'}) }
    assert_instance_of(WWW::Delicious, obj)
  end
  
  def test_initialize_raises_without_account
    assert_raise(ArgumentError) { WWW::Delicious.new() }
    assert_raise(ArgumentError) { WWW::Delicious.new(TEST_USERNAME) }
  end

  
  # =========================================================================
  # These tests check constructor options
  # =========================================================================
  
  def test_initialize_account
    obj = instance()
    assert_equal(@default_username, obj.username)
    assert_equal(@default_password, obj.password)
  end
  
  def test_initialize_option_user_agent
    obj = nil
    useragent = 'MyClass/1.0 (Foo/Bar +http://foo.com/)'
    assert_nothing_raised() { obj = instance(:user_agent => useragent) }
    assert_equal(useragent, obj.user_agent)
  end
  
  def test_initialize_option_user_agent_default
    useragent = instance.user_agent
    assert_match("Ruby/#{RUBY_VERSION}", useragent)
    assert_match("#{WWW::Delicious::NAME}/#{WWW::Delicious::VERSION}", useragent)
  end
  
  
  protected
  #
  # Returns a valid instance of <tt>WWW::Delicious</tt>
  # initialized with given +options+.
  #
  def instance(options = {}, &block)
    username = options.delete(:username) || @default_username
    password = options.delete(:password) || @default_password
    return WWW::Delicious.new(username, password, options, &block)
  end
  

end
