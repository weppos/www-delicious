require 'test_helper'


class DeliciousTest < Test::Unit::TestCase

  TEST_USERNAME = 'username'
  TEST_PASSWORD = 'password'


  def setup
    @delicious = instance
  end


  def test_initialize_should_raise_without_account
    assert_raise(ArgumentError) { WWW::Delicious.new }
    assert_raise(ArgumentError) { WWW::Delicious.new(TEST_USERNAME) }
  end

  def test_initialize_should_set_account_credentials
    assert_equal(TEST_USERNAME, @delicious.username)
    assert_equal(TEST_PASSWORD, @delicious.password)
  end

  def test_initialize_should_allow_option_user_agent
    useragent = 'MyClass/1.0 (Foo/Bar +http://foo.com/)'
    delicious = instance(:user_agent => useragent)
    assert_equal(useragent, delicious.user_agent)
  end

  def test_initialize_should_default_option_user_agent_unless_option
    useragent = instance.user_agent
    assert_match("Ruby/#{RUBY_VERSION}", useragent)
    assert_match("#{WWW::Delicious::NAME}/#{WWW::Delicious::VERSION}", useragent)
  end

  def test_initialize_should_allow_option_base_uri
    base_uri = 'https://ma.gnolia.com/api/mirrord'
    delicious = instance(:base_uri => base_uri)
    assert_equal(URI.parse(base_uri), delicious.base_uri)
  end

  def test_initialize_should_default_option_base_uri_unless_option
    base_uri = instance.base_uri
    assert_equal(URI.parse('https://api.del.icio.us'), base_uri)
  end


  # =========================================================================
  # HTTP Request common checks
  # =========================================================================

  def test_request_raises_without_http_client
    @delicious.http_client = nil
    assert_raise(WWW::Delicious::Error) { @delicious.update }
  end

  def test_request_waits_necessary_time_between_requests
    @delicious.expects(:get_response).times(4).returns(load_fixture('/net_response_success.yml'))
    @delicious.valid_account?   # 1st request
    3.times do |time|
      lr = @delicious.instance_variable_get(:@last_request)
      @delicious.valid_account? # N request
      nr = @delicious.instance_variable_get(:@last_request)
      time_diff = (nr - lr)
      assert !(time_diff < WWW::Delicious::SECONDS_BEFORE_NEW_REQUEST),
            "Request ##{time} run after `#{time_diff}' seconds " +
            "but it should wait at least `#{WWW::Delicious::SECONDS_BEFORE_NEW_REQUEST}' seconds"
    end
  end


  def test_valid_account
    @delicious.expects(:get_response).once.returns(load_fixture('/net_response_success.yml'))
    assert(@delicious.valid_account?)
  end

  def test_invalid_account
    @delicious.expects(:get_response).once.returns(load_fixture('/net_response_invalid_account.yml'))
    assert(!@delicious.valid_account?)
  end


  # =========================================================================
  # Update
  # =========================================================================

  def test_update
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    assert_equal(@delicious.update, Time.parse("2008-08-02T11:55:35Z"))
  end

  def test_update_raises_without_update_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/bundles_all.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.update
    end
    assert_match(/`update`/, error.message)
  end

  def test_update_delicious1
    @delicious.expects(:request).once.returns(mock_response('/response/update.delicious1.xml'))
    assert_equal(@delicious.update, Time.parse("2008-03-12T08:41:20Z"))
  end


  # =========================================================================
  # Bundles
  # =========================================================================

  def test_bundles_all
    @delicious.expects(:request).once.returns(mock_response('/response/bundles_all.xml'))
    expected = [ ['music', %w(ipod mp3 music)], ['pc', %w(computer software hardware)] ]

    results = @delicious.bundles_all
    assert_instance_of(Array, results)
    assert_equal(2, results.length)

    results.each_with_index do |bundle, index|
      assert_instance_of(WWW::Delicious::Bundle, bundle)
      name, tags = expected[index]
      assert_equal(name, bundle.name)
      assert_equal(tags, bundle.tags)
    end
  end

  def test_bundles_all_empty
    @delicious.expects(:request).once.returns(mock_response('/response/bundles_all_empty.xml'))
    results = @delicious.bundles_all
    assert_instance_of(Array, results)
    assert_equal(0, results.length)
  end

  def test_bundles_all_raises_without_bundles_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.bundles_all
    end
    assert_match(/`bundles`/, error.message)
  end


  def test_bundles_set
    @delicious.expects(:request).once.returns(mock_response('/response/bundles_set.xml'))
    assert(@delicious.bundles_set('name', %w(foo bar)))
  end

  def test_bundles_set_raises_with_response_error
    @delicious.expects(:request).once.returns(mock_response('/response/bundles_set_error.xml'))
    error = assert_raise(WWW::Delicious::Error) do
      @delicious.bundles_set('name', %w(foo bar))
    end
    assert_match(/you must supply a bundle name/, error.message)
  end

  def test_bundles_set_raises_without_result_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.bundles_set('name', %w(foo bar))
    end
    assert_match(/`result`/, error.message)
  end


  def test_bundles_delete
    @delicious.expects(:request).once.returns(mock_response('/response/bundles_delete.xml'))
    assert(@delicious.bundles_delete('name'))
  end

  def test_bundles_delete_raises_without_result_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.bundles_delete('name')
    end
    assert_match(/`result`/, error.message)
  end


  # =========================================================================
  # Tags
  # =========================================================================

  def test_tags_get
    @delicious.expects(:request).once.returns(mock_response('/response/tags_get.xml'))
    expected = [ ['activedesktop', 1], ['business', 14] ]

    results = @delicious.tags_get
    assert_instance_of(Array, results)
    assert_equal(2, results.length)

    results.each_with_index do |tag, index|
      assert_instance_of(WWW::Delicious::Tag, tag)
      name, count = expected[index]
      assert_equal(name, tag.name)
      assert_equal(count, tag.count)
    end
  end

  def test_tags_get_empty
    @delicious.expects(:request).once.returns(mock_response('/response/tags_get_empty.xml'))
    results = @delicious.tags_get
    assert_instance_of(Array, results)
    assert_equal(0, results.length)
  end

  def test_tags_get_raises_without_bundles_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.tags_get
    end
    assert_match(/`tags`/, error.message)
  end


  def test_tags_rename
    @delicious.expects(:request).once.returns(mock_response('/response/tags_rename.xml'))
    assert(@delicious.tags_rename('old', 'new'))
  end

  def test_tags_rename_raises_without_result_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.tags_rename('foo', 'bar')
    end
    assert_match(/`result`/, error.message)
  end


  # =========================================================================
  # Posts
  # =========================================================================

  def test_posts_get
    @delicious.expects(:request).once.returns(mock_response('/response/posts_get.xml'))
    results = @delicious.posts_get
    assert_instance_of(Array, results)
    assert_equal(3, results.length)
    assert_equal('New to Git? - GitHub', results.first.title)
    assert_equal('.c( whytheluckystiff )o. -- The Fully Upturned Bin', results.last.title)
  end

  def test_posts_get_when_no_results
    @delicious.expects(:request).once.returns(mock_response('/response/posts_get_empty.xml'))
    results = @delicious.posts_get
    assert_instance_of(Array, results)
    assert_equal(0, results.length)
  end

  def test_posts_get_raises_without_posts_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.posts_get
    end
    assert_match(/`posts`/, error.message)
  end


  def test_posts_recent
    @delicious.expects(:request).with('/v1/posts/recent',{}).once.returns(mock_response('/response/posts_recent.xml'))
    results = @delicious.posts_recent
    assert_instance_of(Array, results)
    assert_equal(15, results.length)
    assert_equal('New to Git? - GitHub', results.first.title)
    assert_equal('RichText | Lightview for modal dialogs on Rails', results.last.title)
  end

  def test_posts_recent_with_count
    expected_params = {:count => 25}
    @delicious.expects(:request).with('/v1/posts/recent',expected_params).once.returns(mock_response('/response/posts_recent.xml'))
    results = @delicious.posts_recent({:count => 25})
    assert_instance_of(Array, results)
    assert_equal(15, results.length)
    assert_equal('New to Git? - GitHub', results.first.title)
    assert_equal('RichText | Lightview for modal dialogs on Rails', results.last.title)
  end

  def test_posts_recent_raises_over_max_count
    error = assert_raise(WWW::Delicious::Error) do
      @delicious.posts_recent({:count => 101})
    end
    assert_match(/`count`/, error.message)
  end

  def test_posts_recent_raises_without_posts_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.posts_recent
    end
    assert_match(/`posts`/, error.message)
  end


  def test_posts_count
    expected_params = {:results => 1}
    @delicious.expects(:request).with('/v1/posts/all',expected_params).once.returns(mock_response('/response/posts_all.xml'))
    assert_equal(1702, @delicious.posts_count)
  end


  def test_posts_all
    expected_params = {}
    @delicious.expects(:request).with('/v1/posts/all',expected_params).once.returns(mock_response('/response/posts_all.xml'))
    results = @delicious.posts_all
    assert_instance_of(Array, results)
    assert_equal(8, results.length)
    assert_equal('New to Git? - GitHub', results.first.title)
    assert_equal('ASP 101 - Object Oriented ASP: Using Classes in Classic ASP', results.last.title)
  end

  def test_posts_all_in_full
    @delicious.expects(:posts_count).once.returns(333)
    @delicious.expects(:request).with('/v1/posts/all',{:results => 333}).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:count => :all})
  end

  def test_posts_all_when_no_results
    @delicious.expects(:request).once.returns(mock_response('/response/posts_all_empty.xml'))
    results = @delicious.posts_all
    assert_instance_of(Array, results)
    assert_equal(0, results.length)
  end

  def test_posts_all_with_meta_enabled
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?meta=yes")
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:meta => true})
  end

  def test_posts_all_with_meta_disabled
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge(expected_path)
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:meta => false})
  end

  def test_posts_all_with_start
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?start=33")
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:start => 33})
  end

  def test_posts_all_with_count
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?results=345")
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:count => 345})
  end

  def test_posts_all_with_results
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?results=345")
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:results => 345})
  end

  def test_posts_all_with_fromdt
    fromdt = Time.parse('2012-11-01 12:34 AM')
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?fromdt=#{fromdt.iso8601}")
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:fromdt => fromdt})
  end

  def test_posts_all_with_todt
    todt = Time.parse('2012-11-02 12:34 AM')
    expected_path = '/v1/posts/all'
    expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?todt=#{todt.iso8601}")
    @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:todt => todt})
  end

  def test_posts_all_with_fromdt_and_todt
    fromdt = Time.parse('2012-11-01 12:34 AM')
    todt = Time.parse('2012-11-02 12:34 AM')
    expected_path = '/v1/posts/all'
    expected_params = {:fromdt => fromdt.iso8601, :todt => todt.iso8601}
    @delicious.expects(:request).with(expected_path,expected_params).once.returns(mock_response('/response/posts_all.xml'))
    # Would prefer to do the following test instead, but for some reason I don't fully understand yet, REE fails this
    # test while all other rubies are OK:
    # expected_uri = URI.parse(WWW::Delicious::API_BASE_URI).merge("#{expected_path}?fromdt=#{fromdt.iso8601}&todt=#{todt.iso8601}")
    # @delicious.expects(:make_request).with(expected_uri).once.returns(mock_response('/response/posts_all.xml'))
    @delicious.posts_all({:fromdt => fromdt, :todt => todt})
  end

  def test_posts_all_raises_without_posts_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.posts_all
    end
    assert_match(/`posts`/, error.message)
  end


  def test_posts_dates
    @delicious.expects(:request).once.returns(mock_response('/response/posts_dates.xml'))
    results = @delicious.posts_dates
    assert_instance_of(Hash, results)
    assert_equal(10, results.length)
  end

  def test_posts_dates_raises_without_dates_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.posts_dates
    end
    assert_match(/`dates`/, error.message)
  end


  def test_posts_add
    params = {:url => 'http://localhost', :title => 'Just a test'}
    @delicious.expects(:request).times(2).returns(mock_response('/response/posts_add.xml'))
    assert(@delicious.posts_add(WWW::Delicious::Post.new(params)))
    assert(@delicious.posts_add(params))
  end


  def test_posts_delete
    @delicious.expects(:request).once.returns(mock_response('/response/posts_delete.xml'))
    assert(@delicious.posts_delete('test'))
  end

  def test_posts_delete_raises_without_result_root_node
    @delicious.expects(:request).once.returns(mock_response('/response/update.xml'))
    error = assert_raise(WWW::Delicious::ResponseError) do
      @delicious.posts_delete('test')
    end
    assert_match(/`result`/, error.message)
  end



  protected

    # returns a stub instance
    def instance(options = {}, &block)
      WWW::Delicious.new(TEST_USERNAME, TEST_PASSWORD, options, &block)
    end

    def load_testcase(file)
      File.read(TESTCASES_PATH + file)
    end

    def load_fixture(file)
      YAML.load(File.read(FIXTURES_PATH + file))
    end

    def mock_response(file_or_content)
      content = case
        when file_or_content =~ /\.xml$/
          load_testcase(file_or_content)
        when file_or_content =~ /\.yml$/
          load_fixture(file_or_content)
        else
          file_or_content.to_s
      end

      response = mock()
      response.expects(:body).at_least(1).returns(content)
      response
    end

end
