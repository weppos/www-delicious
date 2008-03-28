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


require 'net/https'
require 'rexml/document'
require 'time'
require File.dirname(__FILE__) + '/delicious/bundle'
require File.dirname(__FILE__) + '/delicious/post'
require File.dirname(__FILE__) + '/delicious/tag'
require File.dirname(__FILE__) + '/delicious/errors'


module WWW #:nodoc:
  

  #
  # = WWW::Delicious
  # 
  # //
  # //
  # 
  # == Download and Installation
  # 
  # //
  # 
  # == Documentation
  # 
  # //
  #
  # == Example Usage
  # 
  # //
  #
  # == Basic Usage
  # 
  # //
  # 
  # == Author
  # 
  # //
  # 
  # == License
  # 
  # //
  # 
  # == FeedBack and Bug reports
  # 
  # //
  # 
  # == Changelog
  # 
  # //
  # 
  # == Roadmap
  # 
  # //
  # 
  # 
  # Category::   WWW
  # Package::    WWW::Delicious
  # Author::     Simone Carletti <weppos@weppos.net>
  #
  class Delicious
    
    NAME            = 'WWW::Delicious'
    GEM             = 'www_delicious'
    AUTHOR          = 'Simone Carletti <weppos@weppos.net>'
    VERSION         = '0.0.0'
    STATUS          = 'alpha'
    BUILD           = '$Rev$'.match(/(\d+)/)[1].to_s()
    
    SVN_ID          = '$Id$'
    SVN_REVISION    = '$Rev$'
    SVN_BUILD       = '$Date$'
    
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
    # 
    # === Params
    # username::
    #   a +String+ with the account username
    # password::
    #   a +String+ with the account password
    # options::
    #   an +Hash+ with optional parameters to customize the library behavior
    #   
    # === Options
    # This class accepts additional options provided as a +Hash+ reference.
    # Here's the supported keys reference:
    #
    # [<tt>:user_agent</tt>] 
    #   User agent to display in HTTP requests.
    # 
    def initialize(username, password, options = {}, &block) #  :yields: delicious
      @username, @password = username, password
      self.debug = options[:debug]

      # set API base URI
      @base_uri = URI.parse(API_BASE_URI)

      init_user_agent(options)
      init_http_client(options)
      
      yield self if block_given?
      self # ensure to always return self even if block is given
    end
    

    public
    #
    # Returns the reference to current http client.
    # A new http client is created if none has been initialized before.
    #
    # === Return
    # The <tt>Net::HTTP</tt> instance or +nil+
    # 
    # === Examples
    # 
    #   # nil client
    #   obj.http_client # => nil
    #   
    #   # valid client
    #   # obj.http_client = Net::HTTP.new()
    #   obj.http_client # => Net::HTTP
    #
    def http_client()
      return @http_client
    end

    public
    #
    # Sets the internal http client to +client+.
    #
    # === Params
    # client::
    #   a <tt>Net::HTTP</tt> instance or +nil+ to reset the http client
    # 
    # === Examples
    # 
    #   # nil client
    #   obj.http_client = nil
    #   # http client
    #   obj.http_client = Net::HTTP.new()
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
    # === Return
    # A string with current user agent value.
    #
    def user_agent()
      return @headers['User-Agent']
    end
    
    public
    #
    # Turns debug on/off.
    #
    def debug=(value)
      bool = proc { |str| !['false', false, '0', 0, nil, ''].include?(str) }
      @debug = bool.call(value)
    end
    
    public
    #
    # Returns whether this library is in debug mode.
    #
    def debug?
      return @debug
    end
     
    
    public
    #
    # Returns true if given account credentials are valid.
    # 
    # This method is not "exception safe".
    # It doesn't return false if an HTTP error or any kind of other error occurs,
    # it raises back the exception to the caller instead.
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
    # Checks to see when a user last posted an item.
    # 
    # === Return
    # The last update +Time+ for the user. 
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
    # Retrieves all of a user's bundles.
    # 
    # === Return
    # An +Array+ of <tt>WWW::Delicious::Bundle</tt>.
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
    # Deletes a bundle.
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
    # Retrieves the list of tags and number of times used by the user.
    # 
    # === Return
    # An +Array+ of <tt>WWW::Delicious::Tag</tt>.
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
    # Returns posts matching +options+. 
    # If no date or url is given, most recent date will be used.
    # 
    # === Options
    # tag::
    #   a tag to filter by. 
    #   It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    # dt::
    #   a +Time+ with a tate to filter by.
    # url::
    #   a valid URI to filter by.
    #   It can be either an instance of +URI+ or a +String+.
    # 
    # === Return
    # An +Array+ of <tt>WWW::Delicious::Post</tt>.
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
    # === Options
    # tag::
    #   a tag to filter by. 
    #   It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    # count::
    #   number of items to retrieve. (default: 15, maximum: 100).
    #
    def posts_recent(options = {})
      params = prepare_posts_params(options.clone, [:count, :tag])
      response = request(API_PATH_POSTS_RECENT, params)
      return parse_posts_response(response.body)
    end

    public
    #
    # Returns a list of the most recent posts, filtered by argument.
    # 
    # === Options
    # tag::
    #   a tag to filter by. 
    #   It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
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
    # === Options
    # tag::
    #   a tag to filter by. 
    #   It can be either a <tt>WWW::Delicious::Tag</tt> or a +String+.
    #
    def posts_dates(options = {})
      params = prepare_posts_params(options.clone, [:tag])
      response = request(API_PATH_POSTS_DATES, params)
      return parse_posts_dates_response(response.body)
    end

    public
    #
    # Add a post to del.icio.us.
    #
    def posts_add(post_or_values)
      params = prepare_posts_add_params(post_or_values.clone)
      response = request(API_PATH_POSTS_ADD, params)
      return parse_and_eval_execution_response(response.body)
    end

    public
    #
    # Deletes a post from del.icio.us.
    # 
    # === Params
    # url::
    #   the url of the item.
    #   It can be either an +URI+ or a +String+.
    #
    def posts_delete(url)
      params = prepare_posts_params({:url => url}, [:url])
      response = request(API_PATH_POSTS_DELETE, params)
      return parse_and_eval_execution_response(response.body)
    end

    
    protected
    #
    # Initializes HTTP client.
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
    def default_user_agent()
      return "#{NAME}/#{VERSION} (Ruby/#{RUBY_VERSION})"
    end
    
    
    protected
    #
    # Composes an HTTP query string from an hash of +params+.
    #
    def http_build_query(params = {})
      return params.collect do |k,v| 
        "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}" unless v.nil?
      end.compact.join('&')
    end
    
    protected
    #
    # Sends and HTTP GET request to Delicious API.
    # 
    # This method is 100% compliant with Delicious API reference.
    # It waits at least 1 second between each HTTP request and
    # provides an identifiable user agent by default,
    # or the custom user agent set by +user_agent+ option 
    # when this istance has been created.
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
        raise HTTPError, 
          'You have been throttled.' +
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
      puts "Last request at #{TIME_CONVERTER.call(@last_request)}" if debug?
      diff = Time.now - @last_request
      if diff < SECONDS_BEFORE_NEW_REQUEST
        puts "Sleeping for #{diff} before new request..." if debug?
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
    # Prepares the params for a `bundles_set` request.
    # 
    # === Returns
    # An +Hash+ with params to supply to the HTTP request.
    # 
    # Raises::
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
    # Prepares the params for a `bundles_set` request.
    # 
    # === Returns
    # An +Hash+ with params to supply to the HTTP request.
    # 
    # Raises::
    #
    def prepare_bundles_delete_params(name_or_bundle)
      bundle = prepare_param_bundle(name_or_bundle) do |b|
        raise Error, "Bundle name is empty" if b.name.empty?
      end
      return { :bundle => bundle.name }
    end
    
    protected
    #
    # Prepares the params for a `tags_rename` request.
    # 
    # === Returns
    # An +Hash+ with params to supply to the HTTP request.
    # 
    # Raises::
    #
    def prepare_tags_rename_params(from_name_or_tag, to_name_or_tag)
      from, to = [from_name_or_tag, to_name_or_tag].collect do |v|
        prepare_param_tag(v)
      end
      return { :old => from, :new => to }
    end
    
    protected
    #
    # Prepares the params for a `post_*` request.
    # 
    # === Returns
    # An +Hash+ with params to supply to the HTTP request.
    # 
    # Raises::
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
    # Prepares the params for a `post_add` request.
    # 
    # === Returns
    # An +Hash+ with params to supply to the HTTP request.
    # 
    # Raises::
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
    # Prepares the +bundle+ params.
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
    # Prepares the +tag+ params.
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
    # Checks whether user given params are valid against valid params.
    # 
    # === Params
    # params::
    #   an +Hash+ with user given params to validate
    # valid_params::
    #   an +Array+ of valid params keys to check against
    #   
    # === Examples
    # 
    #   params = {:foo => 1, :bar => 2}
    #   compare_params(params, [:foo, :bar])
    #   # => valid
    #   compare_params(params, [:foo, :bar, :baz])
    #   # => raises
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

    
    module XMLUtils

      public
      #
      # Returns the +xmlattr+ attribute value for given +node+.
      # 
      # If block is given and attrivute value is not nil
      # the content of the block is executed.
      # 
      # === Params
      # node::
      #   The REXML::Element node context
      # xmlattr::
      #   A String corresponding to the name of the XML attribute to search for
      #   
      # === Return
      # The value of the +xmlattr+ if the attribute exists for given +node+,
      # +nil+ otherwise.
      #
      def attribute_value(xmlattr, &block) # :yields: attribute_value
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
