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


# prepend lib folder
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'www/delicious'

# testcase file path
TESTCASE_PATH   = File.dirname(__FILE__) + '/_files' unless defined?(TESTCASE_PATH)
TEST_REAL_TESTS = ENV['DUSERNAME'] && ENV['DPASSWORD'] unless defined?(TEST_REAL_TESTS)


module WWW
  class Delicious 
    module TestCase

      TEST_USERNAME = 'u' unless defined? TEST_USERNAME
      TEST_PASSWORD = 'p' unless defined? TEST_PASSWORD

      def setup
        @default_username = ENV['DUSERNAME'] || TEST_USERNAME
        @default_password = ENV['DPASSWORD'] || TEST_PASSWORD
        @run_online_tests = false
        @run_real_tests   = TEST_REAL_TESTS
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

      protected
      #
      # Returns true if tests that requires an HTTP connection must be skipped.
      #
      def skip_online?
        return !@run_online_tests
      end

      protected
      #
      # Loads a marshaled response for given +path+.
      #
      def load_response(path)
        return Marshal.load(File.read(path))
      end

      protected
      #
      # Loads a marshaled response for given +path+.
      #
      def set_response(content, path = nil)
        path ||= TESTCASE_PATH + '/marshaled_response'
        response = Marshal.load(File.read(path))
        response.instance_variable_set(:@body, content)
        Net::HTTP.response = response
      end
      
    end
  end
end

module Net
  class HTTP < Protocol
    @@offline_response = nil
    
    class << self
      def response()
        r = @@offline_response ||= Marshal.load(File.read(TESTCASE_PATH + '/marshaled_response'))
        @@offline_response = nil
        r
      end
      def response=(r)
        @@offline_response = r
      end
    end
    
    alias :request_online :request
    def request_offline(req, body = nil, &block)
      return self.class.response
    end
    
    # prepare for offline tests
    remove_method :request 
    alias :request :request_offline
  end
end

