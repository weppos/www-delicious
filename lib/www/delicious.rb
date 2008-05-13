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


require 'net/https'
require 'rexml/document'
require 'time'
require File.dirname(__FILE__) + '/delicious/bundle'
require File.dirname(__FILE__) + '/delicious/post'
require File.dirname(__FILE__) + '/delicious/tag'
require File.dirname(__FILE__) + '/delicious/errors'
require File.dirname(__FILE__) + '/delicious/version'


module WWW #:nodoc:


  #
  # = WWW::Delicious
  # 
  # WWW::Delicious is a Ruby client for http://del.icio.us XML API.
  # 
  # It provides both read and write functionalities. 
  # You can read user Posts, Tags and Bundles 
  # but you can create new Posts, Tags and Bundles as well.
  #
  #
  # == Basic Usage
  # 
  # The following is just a basic demonstration of the main features.
  # See the README file for a deeper explanation about how to get the best
  # from WWW::Delicious library.
  # 
  # The examples in this page make the following assumptions
  # * you have a valid del.icio.us account
  # * +username+ is your account username
  # * +password+ is your account password
  # 
  # In order to make a query you first need to create
  # a new WWW::Delicious instance as follows:
  #
  #   require 'www/delicious'
  # 
  #   username = 'my delicious username'
  #   password = 'my delicious password'
  #
  #   d = WWW::Delicious.new(username, password)
  # 
  # The constructor accepts some additional options.
  # For instance, if you want to customize the user agent:
  # 
  #   d = WWW::Delicious.new(username, password, :user_agent => 'FooAgent')
  #   
  # Now you can use any of the API methods available.
  # 
  # For example, you may want to know when your account was last updated
  # to check whether someone else made some changes on behalf of you:
  # 
  #   datetime = d.update # => Wed Mar 12 08:41:20 UTC 2008
  #   
  # Because the answer is a valid +Time+ instance, you can format it with +strftime+.
  #   
  #   datetime = d.update # => Wed Mar 12 08:41:20 UTC 2008
  #   datetime.strftime('%Y') # => 2008
  # 
  # 
  # 
  # Category::   WWW
  # Package::    WWW::Delicious
  # Author::     Simone Carletti <weppos@weppos.net>
  #
  class Delicious
    
    NAME            = 'WWW::Delicious'
    GEM             = 'www-delicious'
    AUTHOR          = 'Simone Carletti <weppos@weppos.net>'
    VERSION         = defined?(Version) ? Version::STRING : nil
    STATUS          = 'alpha'
    BUILD           = ''.match(/(\d+)/).to_a.first
    
    # del.icio.us account username
    attr_reader :username
    
    # del.icio.us account password
    attr_reader :password

    
    # API Base URL
    API_BASE_URI    = 'https://api.del.icio.us'

    # API Path Update
    API_PATH_UPDATE         = '/v1/posts/update';

    # API Path All Bundles
    API_PATH_BUNDLES_ALL    = '/v1/tags/bundles/all';
    # API Path Set Bundle
    API_PATH_BUNDLES_SET    = '/v1/tags/bundles/set';
    # API Path Delete Bundle
    API_PATH_BUNDLES_DELETE = '/v1/tags/bundles/delete';

    # API Path Get Tags
    API_PATH_TAGS_GET       = '/v1/tags/get';
    # API Path Rename Tag
    API_PATH_TAGS_RENAME    = '/v1/tags/rename';

    # API Path Get Posts
    API_PATH_POSTS_GET      = '/v1/posts/get';
    # API Path Recent Posts
    API_PATH_POSTS_RECENT   = '/v1/posts/recent';
    # API Path All Posts
    API_PATH_POSTS_ALL      = '/v1/posts/all';
    # API Path Posts by Dates
    API_PATH_POSTS_DATES    = '/v1/posts/dates';
    # API Path Add Post
    API_PATH_POSTS_ADD      = '/v1/posts/add';
    # API Path Delete Post
    API_PATH_POSTS_DELETE   = '/v1/posts/delete';
    
    # Time to wait before sending a new request, in seconds
    SECONDS_BEFORE_NEW_REQUEST = 1
    
    # Time converter converts a Time instance into the format
    # requested by Delicious API
    TIME_CONVERTER = lambda { |time| time.iso8601() }
    
    
    public
    #
    # Constructs a new <tt>WWW::Delicious</tt> object 
    # with given +username+ and +password+.
    #   
    #   # create a new object with username 'user' and password 'psw
    #   obj = WWW::Delicious('user', 'psw')
    #   # => self
    # 
    # If a block is given, the instance is passed to the block
    # but this method always returns the instance itself.
    # 
    #   WWW::Delicious('user', 'psw') do |d|
    #     d.update() # => Fri May 02 18:02:48 UTC 2008
    #   end
    #   # => self
    #   
    # === Options
    # This class accepts an Hash with additional options.
    # Here's the list of valid keys:
    #
    # <tt>:user_agent</tt>:: User agent to display in HTTP requests.
    # 
    def initialize(username, password, options = {}, &block) #  :yields: delicious
      @username, @password = username.to_s, password.to_s

      # set API base URI
      @base_uri = URI.parse(API_BASE_URI)

      init_user_agent(options)
      init_http_client(options)
      
      yield self if block_given?
      self # ensure to always return self even if block is given
    end
    

    public
    #
    # Returns the reference to current <tt>@http_client</tt>.
    # The http is always valid unless it has been previously set to +nil+.
    # 
    #   # nil client
    #   obj.http_client # => nil
    #   
    #   # valid client
    #   obj.http_client # => Net::HTTP
    #
    def http_client()
      return @http_client
    end

    public
    #
    # Sets the internal <tt>@http_client</tt> to +client+.
    #
    #   # nil client
    #   obj.http_client = nil
    # 
    #   # http client
    #   obj.http_client = Net::HTTP.new()
    # 
    #   # invalid client
    #   obj.http_client = 'foo' # => ArgumentError
    # 
    def http_client=(client)
      unless client.kind_of?(Net::HTTP) or client.nil?
        raise ArgumentError, "`client` expected to be a kind of `Net::HTTP`, `#{client.class}` given"
      end
      @http_client = client
    end

    public
    #
    # Returns current user agent string.
    #
    def user_agent()
      return @headers['User-Agent']
    end
    
    
    public
    #
    # Returns true if given account credentials are valid.
    # 
    #   d = WWW::Delicious.new('username', 'password')
    #   d.valid_account? # => true
    # 
    #   d = WWW::Delicious.new('username', 'invalid_password')
    #   d.valid_account? # => false
    # 
    # This method is not "exception safe".
    # It doesn't return false if an HTTP error or any kind of other error occurs,
    # it raises back the exception to the caller instead.
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def valid_account?
      update()
      return true
    rescue HTTPError => e
      return false if e.message =~ /invalid username or password/i
      raise 
    end

    public
    #
    # Checks to see when a user last posted an item
    # and returns the last update +Time+ for the user.
    # 
    #   d.update() # => Fri May 02 18:02:48 UTC 2008
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def update()
      response = request(API_PATH_UPDATE)
      return parse_update_response(response.body)
    end
    
    public
    #
    # Retrieves all of a user's bundles
    # and returns an array of <tt>WWW::Delicious::Bundle</tt>.
    # 
    #   d.bundles_all() # => [#<WWW::Delicious::Bundle>, #<WWW::Delicious::Bundle>, ...]
    #   d.bundles_all() # => []
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def bundles_all()
      response = request(API_PATH_BUNDLES_ALL)
      return parse_bundles_all_response(response.body)
    end
    
    public
    #
    # Assignes a set of tags to a single bundle, 
    # wipes away previous settings for bundle.
    # 
    #   # create from a bundle
    #   d.bundles_set(WWW::Delicious::Bundle.new('MyBundle'), %w(foo bar))
    # 
    #   # create from a string
    #   d.bundles_set('MyBundle', %w(foo bar))
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def bundles_set(bundle_or_name, tags = [])
      params = prepare_bundles_set_params(bundle_or_name, tags)
      response = request(API_PATH_BUNDLES_SET, params)
      return parse_and_eval_execution_response(response.body)
    end
    
    public
    #
    # Deletes +bundle_or_name+ bundle from del.icio.us.
    # +bundle_or_name+ can be either a WWW::Delicious::Bundle instance 
    # or a string with the name of the bundle.
    # 
    # This method doesn't care whether the exists.
    # If not, the execution will silently return without rising any error.
    # 
    #   # delete from a bundle
    #   d.bundles_delete(WWW::Delicious::Bundle.new('MyBundle'))
    # 
    #   # delete from a string
    #   d.bundles_delete('MyBundle', %w(foo bar))
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def bundles_delete(bundle_or_name)
      params = prepare_bundles_delete_params(bundle_or_name)
      response = request(API_PATH_BUNDLES_DELETE, params)
      return parse_and_eval_execution_response(response.body)
    end
    
    public
    #
    # Retrieves the list of tags and number of times used by the user
    # and returns an array of <tt>WWW::Delicious::Tag</tt>.
    # 
    #   d.tags_get() # => [#<WWW::Delicious::Tag>, #<WWW::Delicious::Tag>, ...]
    #   d.tags_get() # => []
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def tags_get()
      response = request(API_PATH_TAGS_GET)
      return parse_tags_get_response(response.body)
    end
    
    public
    #
    # Renames an existing tag with a new tag name.
    # 
    #   # rename from a tag
    #   d.bundles_set(WWW::Delicious::Tag.new('old'), WWW::Delicious::Tag.new('new'))
    # 
    #   # rename from a string
    #   d.bundles_set('old', 'new')
    # 
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def tags_rename(from_name_or_tag, to_name_or_tag)
      params = prepare_tags_rename_params(from_name_or_tag, to_name_or_tag)
      response = request(API_PATH_TAGS_RENAME, params)
      return parse_and_eval_execution_response(response.body)
    end
    
    public
    #
    # Returns an array of <tt>WWW::Delicious::Post</tt> matching +options+.
    # If no option is given, the last post is returned.
    # If no date or url is given, most recent date will be used.
    # 
    #   d.posts_get() # => [#<WWW::Delicious::Post>, #<WWW::Delicious::Post>, ...]
    #   d.posts_get() # => []
    # 
    #   # get all posts tagged with ruby
    #   d.posts_get(:tag => WWW::Delicious::Tag.new('ruby))
    # 
    #   # get all posts matching URL 'http://www.simonecarletti.com'
    #   d.posts_get(:url => URI.parse('http://www.simonecarletti.com'))
    # 
    #   # get all posts tagged with ruby and matching URL 'http://www.simonecarletti.com'
    #   d.posts_get(:tag => WWW::Delicious::Tag.new('ruby),
    #               :url => URI.parse('http://www.simonecarletti.com'))
    # 
    # 
    # === Options
    # <tt>:tag</tt>:: a tag to filter by. It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    # <tt>:dt</tt>::  a +Time+ with a date to filter by.
    # <tt>:url</tt>:: a valid URI to filter by. It can be either an instance of +URI+ or a +String+.
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def posts_get(options = {})
      params = prepare_posts_params(options.clone, [:dt, :tag, :url])
      response = request(API_PATH_POSTS_GET, params)
      return parse_posts_response(response.body)
    end

    public
    #
    # Returns a list of the most recent posts, filtered by argument.
    # 
    #   # get the most recent posts
    #   d.posts_recent()
    # 
    #   # get the 10 most recent posts
    #   d.posts_recent(:count => 10)
    # 
    # 
    # === Options
    # <tt>:tag</tt>::   a tag to filter by. It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    # <tt>:count</tt>:: number of items to retrieve. (default: 15, maximum: 100).
    #
    def posts_recent(options = {})
      params = prepare_posts_params(options.clone, [:count, :tag])
      response = request(API_PATH_POSTS_RECENT, params)
      return parse_posts_response(response.body)
    end

    public
    #
    # Returns a list of all posts, filtered by argument.
    # 
    #   # get all (this is a very expensive query)
    #   d.posts_all()
    # 
    #   # get all posts matching ruby
    #   d.posts_all(:tag => WWW::Delicious::Tag.new('ruby'))
    # 
    # 
    # === Options
    # <tt>:tag</tt>:: a tag to filter by. It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    #
    def posts_all(options = {})
      params = prepare_posts_params(options.clone, [:tag])
      response = request(API_PATH_POSTS_ALL, params)
      return parse_posts_response(response.body)
    end

    public
    #
    # Returns a list of dates with the number of posts at each date.
    # 
    #   # get number of posts per date
    #   d.posts_dates()
    #   # => { '2008-05-05' => 12, '2008-05-06' => 3, ... }
    # 
    #   # get number posts per date tagged as ruby
    #   d.posts_dates(:tag => WWW::Delicious::Tag.new('ruby'))
    #   # => { '2008-05-05' => 10, '2008-05-06' => 3, ... }
    # 
    # 
    # === Options
    # <tt>:tag</tt>:: a tag to filter by. It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    #
    def posts_dates(options = {})
      params = prepare_posts_params(options.clone, [:tag])
      response = request(API_PATH_POSTS_DATES, params)
      return parse_posts_dates_response(response.body)
    end

    public
    #
    # Add a post to del.icio.us.
    # +post_or_values+ can be either a +WWW::Delicious::Post+ instance
    # or a Hash of params. This method accepts all params available
    # to initialize a new +WWW::Delicious::Post+.
    # 
    #   # add a post from WWW::Delicious::Post
    #   d.posts_add(WWW::Delicious::Post.new(:url => 'http://www.foobar.com', :title => 'Hello world!'))
    # 
    #   # add a post from values
    #   d.posts_add(:url => 'http://www.foobar.com', :title => 'Hello world!')
    # 
    #
    def posts_add(post_or_values)
      params = prepare_posts_add_params(post_or_values.clone)
      response = request(API_PATH_POSTS_ADD, params)
      return parse_and_eval_execution_response(response.body)
    end

    public
    #
    # Deletes the post matching given +url+ from del.icio.us.
    # +url+ can be either an URI instance or a string representation of a valid URL.
    # 
    # This method doesn't care whether a post with given +url+ exists.
    # If not, the execution will silently return without rising any error.
    # 
    #   # delete a post from URI
    #   d.post_delete(URI.parse('http://www.foobar.com/'))
    # 
    #   # delete a post from a string
    #   d.post_delete('http://www.foobar.com/')
    # 
    #
    def posts_delete(url)
      params = prepare_posts_params({:url => url}, [:url])
      response = request(API_PATH_POSTS_DELETE, params)
      return parse_and_eval_execution_response(response.body)
    end

    
    protected
    #
    # Initializes the HTTP client.
    # It automatically enable +use_ssl+ flag according to +@base_uri+ scheme.
    #
    def init_http_client(options)
      http = Net::HTTP.new(@base_uri.host, 443)
      http.use_ssl = true if @base_uri.scheme == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # FIXME: not 100% supported
      self.http_client = http
    end
    
    protected
    #
    # Initializes user agent value for HTTP requests.
    #
    def init_user_agent(options)
      user_agent = options[:user_agent] || default_user_agent()
      @headers ||= {}
      @headers['User-Agent'] = user_agent
    end
    
    protected
    #
    # Creates and returns the default user agent string.
    # 
    # By default, the user agent is composed by the following schema:
    # <tt>NAME/VERSION (Ruby/RUBY_VERSION)</tt>
    # 
    # * +NAME+ is the constant representing this library name
    # * +VERSION+ is the constant representing current library version
    # * +RUBY_VERSION+ is the version of Ruby interpreter the library is interpreted by
    # 
    #   default_user_agent
    #   # => WWW::Delicious/0.1.0 (Ruby/1.8.6)
    #
    def default_user_agent()
      return "#{NAME}/#{VERSION} (Ruby/#{RUBY_VERSION})"
    end
    
    
    protected
    #
    # Composes an HTTP query string from an hash of +options+.
    # The result is URI encoded.
    # 
    #   http_build_query(:foo => 'baa', :bar => 'boo')
    #   # => foo=baa&bar=boo
    #
    def http_build_query(params = {})
      return params.collect do |k,v| 
        "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}" unless v.nil?
      end.compact.join('&')
    end
    
    protected
    #
    # Sends an HTTP GET request to +path+ and appends given +params+.
    # 
    # This method is 100% compliant with Delicious API reference.
    # It waits at least 1 second between each HTTP request and
    # provides an identifiable user agent by default,
    # or the custom user agent set by +user_agent+ option 
    # when this istance has been created.
    # 
    #   request('/v1/api/path', :foo => 1, :bar => 2)
    #   # => sends a GET request to /v1/api/path?foo=1&bar=2
    #
    def request(path, params = {})
      raise Error, 'Invalid HTTP Client' unless http_client
      wait_before_new_request

      uri = @base_uri.merge(path)
      uri.query = http_build_query(params) unless params.empty?

      begin
        @last_request = Time.now  # see #wait_before_new_request
        @last_request_uri = uri   # useful for debug
        response = http_client.start do |http|
          req = Net::HTTP::Get.new(uri.request_uri, @headers)
          req.basic_auth(@username, @password)
          http.request(req)
        end
      rescue => e # catch EOFError, SocketError and more
        raise HTTPError, e.message
      end

      case response
        when Net::HTTPSuccess
          return response
        when Net::HTTPUnauthorized        # 401
          raise HTTPError, 'Invalid username or password'
        when Net::HTTPServiceUnavailable  # 503
          raise HTTPError, 'You have been throttled.' +
            'Please ensure you are waiting at least one second before each request.'
        else
          raise HTTPError, "HTTP #{response.code}: #{response.message}"
      end
    end
    
    protected
    #
    # Delicious API reference requests to wait AT LEAST ONE SECOND 
    # between queries or the client is likely to get automatically throttled.
    # 
    # This method calculates the difference between current time
    # and the last request time and wait for the necessary time to meet
    # SECONDS_BEFORE_NEW_REQUEST requirement.
    # 
    # The difference is not rounded. If you only have to wait for 0.034 seconds
    # then your don't have to wait 0 or 1 seconds, but 0.034 seconds!
    #
    def wait_before_new_request()
      return unless @last_request # this is the first request
      # puts "Last request at #{TIME_CONVERTER.call(@last_request)}" if debug?
      diff = Time.now - @last_request
      if diff < SECONDS_BEFORE_NEW_REQUEST
        # puts "Sleeping for #{diff} before new request..." if debug?
        sleep(SECONDS_BEFORE_NEW_REQUEST - diff) 
      end
    end
    
    
    protected
    #
    # Parses the response +body+ and runs a common set of validators.
    #
    def parse_and_validate_response(body, options = {})
      dom = REXML::Document.new(body)
      
      if (value = options[:root_name]) && dom.root.name != value
        raise ResponseError, "Invalid response, root node is not `#{value}`"
      end
      if (value = options[:root_text]) && dom.root.text != value
        raise ResponseError, value
      end

      return dom
    end
    
    protected
    #
    # Parses and evaluates the response returned by an execution,
    # usually an update/delete/insert operation.
    #
    def parse_and_eval_execution_response(body)
      dom = parse_and_validate_response(body, :root_name => 'result')

      rsp = dom.root.attribute_value(:code)
      rsp = dom.root.text if rsp.nil?
      raise Error, "Invalid response, #{rsp}" unless %w(done ok).include?(rsp)
    end
    
    protected
    #
    # Parses the response of an 'update' request.
    #
    def parse_update_response(body)
      dom = parse_and_validate_response(body, :root_name => 'update')
      return dom.root.attribute_value(:time) { |v| Time.parse(v) }
    end
    
    protected
    #
    # Parses the response of a 'bundles_all' request
    # and returns an array of <tt>WWW::Delicious::Bundle</tt>.
    #
    def parse_bundles_all_response(body)
      dom = parse_and_validate_response(body, :root_name => 'bundles')
      bundles = []
      
      dom.root.elements.each('bundle') { |xml| bundles << Bundle.from_rexml(xml) }
      return bundles
    end
    
    protected
    #
    # Parses the response of a 'tags_get' request
    # and returns an array of <tt>WWW::Delicious::Tag</tt>.
    #
    def parse_tags_get_response(body)
      dom = parse_and_validate_response(body, :root_name => 'tags')
      tags = []
      
      dom.root.elements.each('tag') { |xml| tags << Tag.new(xml) }
      return tags
    end
    
    protected
    #
    # Parses a response containing a list of Posts
    # and returns an array of <tt>WWW::Delicious::Post</tt>.
    #
    def parse_posts_response(body)
      dom = parse_and_validate_response(body, :root_name => 'posts')
      posts = []
      
      dom.root.elements.each('post') { |xml| posts << Post.new(xml) }
      return posts
    end
    
    protected
    #
    # Parses the response of a 'posts_dates' request
    # and returns an +Hash+ of date => count.
    #
    def parse_posts_dates_response(body)
      dom = parse_and_validate_response(body, :root_name => 'dates')
      results = {}
      
      dom.root.elements.each('date') do |xml|
        date  = xml.attribute_value(:date) 
        count = xml.attribute_value(:count).to_i()
        results[date] = count
      end
      return results
    end
    
    
    protected
    #
    # Prepares the params for a `bundles_set` call
    # and returns a Hash with the params ready for the HTTP request.
    # 
    # Raises::  WWW::Delicious::Error
    #
    def prepare_bundles_set_params(name_or_bundle, tags = [])
      bundle = prepare_param_bundle(name_or_bundle, tags) do |b|
        raise Error, "Bundle name is empty" if b.name.empty?
        raise Error, "Bundle must contain at least one tag" if b.tags.empty?
      end

      return {
        :bundle => bundle.name,
        :tags   => bundle.tags.join(' '),
      }
    end
    
    protected
    #
    # Prepares the params for a `bundles_set` call
    # and returns a Hash with the params ready for the HTTP request.
    # 
    # Raises::  WWW::Delicious::Error
    #
    def prepare_bundles_delete_params(name_or_bundle)
      bundle = prepare_param_bundle(name_or_bundle) do |b|
        raise Error, "Bundle name is empty" if b.name.empty?
      end
      return { :bundle => bundle.name }
    end
    
    protected
    #
    # Prepares the params for a `tags_rename` call
    # and returns a Hash with the params ready for the HTTP request.
    # 
    # Raises::  WWW::Delicious::Error
    #
    def prepare_tags_rename_params(from_name_or_tag, to_name_or_tag)
      from, to = [from_name_or_tag, to_name_or_tag].collect do |v|
        prepare_param_tag(v)
      end
      return { :old => from, :new => to }
    end
    
    protected
    #
    # Prepares the params for a `post_*` call
    # and returns a Hash with the params ready for the HTTP request.
    # 
    # Raises::  WWW::Delicious::Error
    #
    def prepare_posts_params(params, allowed_params = [])
      compare_params(params, allowed_params)
      
      # we don't need to check whether the following parameters
      # are valid for this request because compare_params
      # would raise if an invalid param is supplied
      
      params[:tag]    = prepare_param_tag(params[:tag])  if params[:tag]
      params[:dt]     = TIME_CONVERTER.call(params[:dt]) if params[:dt]
      params[:url]    = URI.parse(params[:url])          if params[:url]
      params[:count]  = if value = params[:count]
        raise Error, 'Expected `count` <= 100' if value.to_i() > 100 # requirement
        value.to_i()
      else
        15 # default value
      end
      
      return params
    end
    
    protected
    #
    # Prepares the params for a `post_add` call
    # and returns a Hash with the params ready for the HTTP request.
    # 
    # Raises::  WWW::Delicious::Error
    #
    def prepare_posts_add_params(post_or_values)
      post = case post_or_values
      when WWW::Delicious::Post
        post_or_values
      when Hash
        value = Post.new(post_or_values)
        raise ArgumentError, 'Both `url` and `title` are required' unless value.api_valid?
        value
      else
        raise ArgumentError, 'Expected `args` to be `WWW::Delicious::Post` or `Hash`'
      end
      return post.to_params()
    end
    
    protected
    #
    # Prepares the +bundle+ params for an API request.
    # 
    # If +name_or_bundle+ is a string,
    # creates a new <tt>WWW::Delicious::Bundle</tt> with
    # +name_or_bundle+ as name and a collection of +tags+.
    # If +name_or_bundle+, +tags+ is ignored.
    #
    def prepare_param_bundle(name_or_bundle, tags = [], &block) #  :yields: bundle
      bundle = case name_or_bundle
      when WWW::Delicious::Bundle
        name_or_bundle
      else
        Bundle.new(name_or_bundle.to_s(), tags)
      end
      yield(bundle) if block_given?
      return bundle
    end
    
    protected
    #
    # Prepares the +tag+ params for an API request.
    # 
    # If +name_or_tag+ is a string,
    # it creates a new <tt>WWW::Delicious::Tag</tt> with
    # +name_or_tag+ as name.
    #
    def prepare_param_tag(name_or_tag, &block) #  :yields: tag
      tag = case name_or_tag
      when WWW::Delicious::Tag
        name_or_tag
      else
        Tag.new(:name => name_or_tag.to_s())
      end
      
      yield(tag) if block_given?
      raise "Invalid `tag` value supplied" unless tag.api_valid?

      return tag
    end
    
    protected
    #
    # Checks whether user given +params+ are valid against a defined collection of +valid_params+.
    # 
    # === Examples
    # 
    #   params = {:foo => 1, :bar => 2}
    #
    #   compare_params(params, [:foo, :bar])
    #   # => valid
    # 
    #   compare_params(params, [:foo, :bar, :baz])
    #   # => raises
    # 
    #   compare_params(params, [:foo])
    #   # => raises
    # 
    # Raises::  WWW::Delicious::Error
    #
    def compare_params(params, valid_params)
      raise ArgumentError, "Expected `params` to be a kind of `Hash`" unless params.kind_of?(Hash)
      raise ArgumentError, "Expected `valid_params` to be a kind of `Array`" unless valid_params.kind_of?(Array)

      # compute options difference
      difference = params.keys - valid_params
      raise Error, 
        "Invalid params: `#{difference.join('`, `')}`" unless difference.empty?
    end

    
    module XMLUtils #:nodoc:

      public
      #
      # Returns the +xmlattr+ attribute value for given +node+.
      # 
      # If block is given and attribute value is not nil,
      # the content of the block is executed.
      # 
      # === Examples
      # 
      #   dom = REXML::Document.new('<a name="1"><b>foo</b><b>bar</b></a>')
      # 
      #   dom.root.attribute_value(:name)
      #   # => "1"
      # 
      #   dom.root.attribute_value(:name) { |v| v.to_i }
      #   # => 1
      # 
      #   dom.root.attribute_value(:foo)
      #   # => nil
      # 
      #   dom.root.attribute_value(:name) { |v| v.to_i }
      #   # => nil
      #
      def attribute_value(xmlattr, &block) #:nodoc:
        value = if attr = self.attribute(xmlattr.to_s())
            attr.value()
          else
            nil
          end
        value = yield value if !value.nil? and block_given?
        return value
      end

    end

  end
end


module REXML # :nodoc:
  class Element < Parent # :nodoc:
    include WWW::Delicious::XMLUtils
  end
end
