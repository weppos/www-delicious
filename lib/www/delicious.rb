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
      return parse_bundles_set_response(response.body)
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
      return parse_bundles_delete_response(response.body)
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
      return parse_tags_rename_response(response.body)
    end
    
    public
    #
    # Retrieves the list of tags and number of times used by the user.
    # 
    # === Return
    # An +Array+ of <tt>WWW::Delicious::Post</tt>.
    # 
    # Raises::  WWW::Delicious::Error
    # Raises::  WWW::Delicious::HTTPError
    # Raises::  WWW::Delicious::ResponseError
    #
    def posts_get(options = {})
      params = prepare_posts_get_params(options)
      response = request(API_PATH_POSTS_GET, params)
      return parse_posts_get_response(response.body)
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
        response
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
      diff = @last_request - Time.now
      sleep(SECONDS_BEFORE_NEW_REQUEST - diff) if diff < SECONDS_BEFORE_NEW_REQUEST
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
    # Parses the response of a 'bundles_set' request.
    #
    def parse_bundles_set_response(body)
      parse_and_validate_response(body, 
        :root_name => 'result', :root_value => 'ok')
    end
    
    protected
    #
    # Parses the response of a 'bundles_delete' request.
    #
    def parse_bundles_delete_response(body)
      parse_and_validate_response(body, 
        :root_name => 'result', :root_value => 'done')
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
    # Parses the response of a 'tags_rename' request.
    #
    def parse_tags_rename_response(body)
      parse_and_validate_response(body, 
        :root_name => 'result', :root_value => 'done')
    end
    
    protected
    #
    # Parses the response of a 'posts_get' request
    # and returns an array of <tt>WWW::Delicious::Post</tt>.
    #
    def parse_posts_get_response(body)
      dom = parse_and_validate_response(body, :root_name => 'posts')
      posts = []
      
      dom.root.elements.each('post') { |xml| posts << Post.new(xml) }
      return posts
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
    def prepare_bundles_delete_params(name_or_bundle, tags = [])
      bundle = prepare_param_bundle(name_or_bundle, tags) do |b|
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
      from = prepare_param_tag(from_name_or_tag) do |t|
        raise Error, "Original tag name is empty"    if t.name.empty?
      end
      to   = prepare_param_tag(to_name_or_tag) do |t|
        raise Error, "Destination tag name is empty" if t.name.empty?
      end
      return { :old => from.name, :new => to.name }
    end
    
    protected
    #
    # Prepares the params for a `post_get` request.
    # 
    # === Returns
    # An +Hash+ with params to supply to the HTTP request.
    # 
    # Raises::
    #
    def prepare_post_get_params(options)
      diff = options.keys - [:url, :tag, :dt]
      raise Error, "Invalid options: `#{diff.join('`, `')}`" unless diff.empty?
      
      # TODO: filter values
      return options
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
        Tag.new(name_or_tag.to_s())
      end
      yield(tag) if block_given?
      return tag
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
