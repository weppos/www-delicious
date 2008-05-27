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


class DeliciousTest < Test::Unit::TestCase
  include WWW::Delicious::TestCase
  
  
  # =========================================================================
  # Constructor behavior
  # =========================================================================
  
  def test_initialize
    assert_nothing_raised() do 
      assert_instance_of(WWW::Delicious, WWW::Delicious.new(TEST_USERNAME, TEST_PASSWORD))
    end
  end
  
  def test_initialize_with_block
    obj = instance do |delicious|
      assert_instance_of(WWW::Delicious, delicious)
    end
    assert_instance_of(WWW::Delicious, obj)
  end
  
  def test_initialize_with_options
    assert_nothing_raised() do
      assert_instance_of(WWW::Delicious, WWW::Delicious.new(TEST_USERNAME, TEST_PASSWORD, {:user_agent => 'ruby/test'}))
    end
  end
  
  def test_initialize_raises_without_account
    assert_raise(ArgumentError) { WWW::Delicious.new() }
    assert_raise(ArgumentError) { WWW::Delicious.new(TEST_USERNAME) }
  end

  
  # =========================================================================
  # Constructor options
  # =========================================================================
  
  def test_initialize_account
    obj = instance()
    assert_equal(@default_username, obj.username)
    assert_equal(@default_password, obj.password)
  end
  
  def test_initialize_option_user_agent
    useragent = 'MyClass/1.0 (Foo/Bar +http://foo.com/)'
    assert_nothing_raised() do 
      obj = instance(:user_agent => useragent)
      assert_equal(useragent, obj.user_agent)
    end
  end
  
  def test_initialize_option_user_agent_default
    useragent = instance.user_agent
    assert_match("Ruby/#{RUBY_VERSION}", useragent)
    assert_match("#{WWW::Delicious::NAME}/#{WWW::Delicious::VERSION}", useragent)
  end
  
  def test_initialize_option_base_uri
    base_uri = 'https://ma.gnolia.com/api/mirrord'
    assert_nothing_raised() do 
      obj = instance(:base_uri => base_uri)
      assert_equal(URI.parse(base_uri), obj.base_uri)
    end
  end
  
  def test_initialize_option_base_uri_default
    base_uri = instance.base_uri
    assert_equal(URI.parse('https://api.del.icio.us'), base_uri)
  end

  
  # =========================================================================
  # These tests check the low level HTTP request workflow
  # Even if #request is a protected method, it is so important that
  # we must test it separately as we did for a few other similar methods.
  # =========================================================================
  
  def test_request_raises_without_http_client
    obj = instance
    obj.http_client = nil
    assert_raise(WWW::Delicious::Error) { obj.send(:request, '/foo') }
  end
  
  def test_request_waits_necessary_time_between_requests
    # use valid_account? as a safe request to prevent tests 
    # run with invalid credential to fail
    r = File.read(TESTCASE_PATH + '/update_success.xml')
    
    obj = instance
    set_response(r)
    obj.valid_account? # 1st request

    3.times do |time|
      lr = obj.instance_variable_get(:@last_request)
      set_response(r)
      obj.valid_account? # N request
      nr = obj.instance_variable_get(:@last_request)
      assert((nr - lr) > WWW::Delicious::SECONDS_BEFORE_NEW_REQUEST)
    end
  end

  
  # =========================================================================
  # Update
  # =========================================================================
  
  def test_update
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    results = nil
    assert_nothing_raised() { results = instance.update() }
    assert_equal(results, Time.parse("2008-03-12T08:41:20Z"))
  end
  
  def test_update_raises_without_update_root_node
    set_response(File.read(TESTCASE_PATH + '/bundles_all_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.update()
    end
    assert_match(/`update`/, exception.message)
  end  

  
  # =========================================================================
  # Bundles
  # =========================================================================
  # Test all bundle calls and related methods.
  # * bundles_all
  # * bundles_set
  # * bundles_delete
  
  def test_bundles_all
    set_response(File.read(TESTCASE_PATH + '/bundles_all_success.xml'))
    results = nil
    
    assert_nothing_raised() { results = instance.bundles_all() }
    assert_instance_of(Array, results)
    assert_equal(2, results.length)
    
    expected = [
      ['music', %w(ipod mp3 music)],
      ['pc', %w(computer software hardware)],
    ]
    
    results.each_with_index do |bundle, index|
      assert_instance_of(WWW::Delicious::Bundle, bundle)
      name, tags = expected[index]
      assert_equal(name, bundle.name)
      assert_equal(tags, bundle.tags)
    end
  end
  
  def test_bundles_all_empty
    set_response(File.read(TESTCASE_PATH + '/bundles_all_success_empty.xml'))
    results = nil
    assert_nothing_raised() { results = instance.bundles_all() }
    assert_instance_of(Array, results)
    assert_equal(0, results.length)
  end
  
  def test_bundles_all_raises_without_bundles_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.bundles_all()
    end
    assert_match(/`bundles`/, exception.message)
  end


  def test_bundles_set
    set_response(File.read(TESTCASE_PATH + '/bundles_set_success.xml'))
    assert_nothing_raised() { instance.bundles_set('name', %w(foo bar)) }
  end
  
  def test_bundles_delete_raises_without_result_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.bundles_set('name', %w(foo bar))
    end
    assert_match(/`result`/, exception.message)
  end

  
  def test_bundles_delete
    set_response(File.read(TESTCASE_PATH + '/bundles_delete_success.xml'))
    assert_nothing_raised() { instance.bundles_delete('name') }
  end
  
  def test_bundles_delete_raises_without_result_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.bundles_delete('name')
    end
    assert_match(/`result`/, exception.message)
  end

  
  # =========================================================================
  # Tags
  # =========================================================================
  # Test all tag calls and related methods.
  # * tags_get
  # * tags_rename

  
  def test_tags_get
    set_response(File.read(TESTCASE_PATH + '/tags_get_success.xml'))
    results = nil

    assert_nothing_raised() { results = instance.tags_get() }
    assert_instance_of(Array, results)
    assert_equal(2, results.length)
    
    expected = [
      ['activedesktop', 1],
      ['business', 14],
    ]
    
    results.each_with_index do |tag, index|
      assert_instance_of(WWW::Delicious::Tag, tag)
      name, count = expected[index]
      assert_equal(name, tag.name)
      assert_equal(count, tag.count)
    end
  end
  
  def test_tags_get_empty
    set_response(File.read(TESTCASE_PATH + '/tags_get_success_empty.xml'))
    results = nil
    assert_nothing_raised() { results = instance.tags_get() }
    assert_instance_of(Array, results)
    assert_equal(0, results.length)
  end
  
  def test_tags_get_raises_without_bundles_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.tags_get()
    end
    assert_match(/`tags`/, exception.message)
  end

  
  def test_tags_rename
    set_response(File.read(TESTCASE_PATH + '/tags_rename_success.xml'))
    assert_nothing_raised() { instance.tags_rename('old', 'new') }
  end
  
  def test_tags_rename_raises_without_result_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.tags_rename('old', 'new')
    end
    assert_match(/`result`/, exception.message)
  end

  
  # =========================================================================
  # These tests check posts_get call and all related methods.
  # TODO: as soon as a full offline test system is ready,
  # remove protected methods tests .
  # =========================================================================
  
  def test_posts_get
  end

  
  # =========================================================================
  # These tests check posts_recent call and all related methods.
  # TODO: as soon as a full offline test system is ready,
  # remove protected methods tests .
  # =========================================================================
  
  def test_posts_recent
  end
  
  
  # =========================================================================
  # These tests check posts_all call and all related methods.
  # TODO: as soon as a full offline test system is ready,
  # remove protected methods tests .
  # =========================================================================
  
  def test_posts_all
  end
  
  
  # =========================================================================
  # These tests check posts_dates call and all related methods.
  # =========================================================================
  
  def test_posts_dates
    set_response(File.read(TESTCASE_PATH + '/posts_dates_success.xml'))
    results = nil
    assert_nothing_raised() { results = instance.posts_dates() }
    assert_instance_of(Hash, results)
  end
  
  def test_posts_dates_raises_without_dates_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.posts_dates()
    end
    assert_match(/`dates`/, exception.message)
  end
  
  # =========================================================================
  # These tests check posts_add call and all related methods.
  # =========================================================================
  
  def test_posts_add
    params = {:url => 'http://localhost', :title => 'Just a test'}
    
    set_response(File.read(TESTCASE_PATH + '/posts_add_success.xml'))
    assert_nothing_raised() { instance.posts_add(WWW::Delicious::Post.new(params)) }
    
    set_response(File.read(TESTCASE_PATH + '/posts_add_success.xml'))
    assert_nothing_raised() { instance.posts_add(params) }
  end

  
  # =========================================================================
  # These tests check posts_delete call and all related methods.
  # =========================================================================
  
  def test_posts_delete
    set_response(File.read(TESTCASE_PATH + '/posts_delete_success.xml'))
    assert_nothing_raised() { instance.posts_delete('test') }
  end
  
  def test_posts_delete_raises_without_result_root_node
    set_response(File.read(TESTCASE_PATH + '/update_success.xml'))
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.posts_delete('test')
    end
    assert_match(/`result`/, exception.message)
  end

  
  
  def test_prepare_posts_params
    tag = 'foo'
    count = 30
    url = 'http://localhost'
    dt  = Time.now

    params = { :tag => tag, :url => url, :dt => dt, :count => count }
    results = instance.send(:prepare_posts_params, params, [:tag, :count, :url, :dt])

    assert_kind_of(WWW::Delicious::Tag, results[:tag])
    assert_equal(tag, results[:tag].to_s)
    assert_equal(count, results[:count])
    assert_equal(URI.parse(url), results[:url])
    assert_equal(dt.iso8601(), results[:dt])
  end
  
  def test_prepare_posts_params_raises_unless_hash
    ['foo', %w(foo bar)].each do |params|
      exception = assert_raise(ArgumentError) do 
        instance.send(:prepare_posts_params, params)
      end
      assert_match(/`Hash`/, exception.message)
    end
  end
  
  def test_prepare_posts_params_raises_with_unknown_params
    params = {:tag => 'foo', :foo => 'bar'}
    exception = assert_raise(WWW::Delicious::Error) do 
      instance.send(:prepare_posts_params, params, [:tag])
    end
    assert_match(/`foo`/, exception.message)
  end


  def test_parse_posts_response
    response = instance.send(:parse_posts_response, 
      File.read(TESTCASE_PATH + '/posts_success.xml'))
    assert_instance_of(Array, response)
    assert_equal(1, response.length)
    
    results = [
      ['http://stacktrace.it/articoli/2008/03/i-7-peccati-capitali-del-recruitment-di-hacker/', 'Stacktrace.it: I 7 peccati capitali del recruitment di hacker'],
    ]
    
    response.each_with_index do |post, index|
      assert_instance_of(WWW::Delicious::Post, post)
      url, title = results[index]
      assert_equal(URI.parse(url), post.url)
      assert_equal(title, post.title)
    end
  end

  def test_parse_posts_response_empty
    response = instance.send(:parse_posts_response, 
      File.read(TESTCASE_PATH + '/posts_success_empty.xml'))
    assert_instance_of(Array, response)
    assert_equal(0, response.length)
  end
  
  def test_parse_posts_response_without_bundles_root_node
    _test_parse_invalid_node(:parse_posts_response, /`posts`/)
  end

  
  
  protected
  #
  # Tests a typical invalid node response.
  #
  def _test_parse_invalid_node(method, match)
    exception = assert_raise(WWW::Delicious::ResponseError) do
      instance.send(method, File.read(TESTCASE_PATH + '/invalid_root.xml'))
    end
    assert_match(match, exception.message)
  end
  
end
