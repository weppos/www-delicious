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
    API_PATH_UPDATE = '/v1/posts/update';
    
    # Time to wait before sending a new request, in seconds
    SECONDS_BEFORE_NEW_REQUEST = 1
    
    
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
    # Returns true if given account credentials are valid.
    # 
    # This method is not "exception safe".
    # It doesn't return false if an HTTP error or any kind of other error occurs,
    # it raises back the exception to the caller instead.
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
    # Check to see when a user last posted an item.
    # Returns the last update time for the user. 
    #
    def update()
      response = request(API_PATH_UPDATE)
      return parse_update_response(response.body)
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
    # Sends and HTTP GET request to Delicious API.
    # 
    # This method is 100% compliant with Delicious API reference.
    # It waits at least 1 second between each HTTP request and
    # provides an identifiable user agent by default,
    # or the custom user agent set by +user_agent+ option 
    # when this istance has been created.
    #
    def request(path)
      raise Error, 'Invalid HTTP Client' unless http_client
      wait_before_new_request
      
      uri = @base_uri.merge(path)
      begin
        @last_request = Time.now # see #wait_before_new_request
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
    # Parses the response of an update request.
    #
    def parse_update_response(body)
      dom = REXML::Document.new(body)
      return xml_node_attribute_value(dom.root, :time) { |v| Time.parse(v) }
    end

    protected
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
    def xml_node_attribute_value(node, xmlattr, &block) # :yields: attribute_value
      value = if attribute = node.attribute(xmlattr.to_s())
          attribute.value()
        else
          nil
        end
      value = yield value if !value.nil? and block_given?
      return value
    end

  end
end
