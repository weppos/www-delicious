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


# Require Net::HTTP 
require 'net/http'


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
    
    # Library metadata
    NAME            = 'WWW::Delicious'
    GEM             = 'www_delicious'
    AUTHOR          = 'Simone Carletti <weppos@weppos.net>'
    VERSION         = '0.0.0'
    STATUS          = 'alpha'
    BUILD           = '$Rev$'.match(/(\d+)/)[1].to_s()

    # SVN metadata
    SVN_ID          = '$Id$'
    SVN_REVISION    = '$Rev$'
    SVN_BUILD       = '$Date$'
    
    
    # del.icio.us account username
    attr_reader :username
    
    # del.icio.us account password
    attr_reader :password

    
    # API Base URL
    API_BASE_URI    = 'https://api.del.icio.us/'
    
    
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
    #   A string with the account username
    # password::
    #   A string with the account password
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
    def initialize(username, password, options = {})
      @username, @password = username, password

      # set API base URI
      @base_uri = URI.parse(API_BASE_URI)

      init_user_agent(options)
      init_http_client(options)
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

    
    protected
    #
    # Initializes HTTP client.
    #
    def init_http_client(options)
      self.http_client = Net::HTTP.new(@base_uri.host)
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
    
  end
end
