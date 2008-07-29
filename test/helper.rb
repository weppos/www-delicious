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

require 'rubygems'
require 'test/unit'
require 'www/delicious'

gem 'mocha'
require 'mocha'

# testcase file path
TESTCASES_PATH   = File.dirname(__FILE__) + '/testcases' unless defined?(TESTCASES_PATH)
FIXTURES_PATH    = File.dirname(__FILE__) + '/fixtures'  unless defined?(FIXTURES_PATH)

# prevent online tests to be run automatically
RUN_ONLINE_TESTS = (ENV['ONLINE'] == "1") unless defined? RUN_ONLINE_TESTS

module Test
  module Unit
    class TestCase
      
      # asserts all given attributes match mapped value in +instance+.
      # +instance+ is the instance to be tested, 
      # +expected_mapping+ is the attribute => value mapping.
      def assert_attributes(instance, expected_mapping)
        expected_mapping.each do |key, value|
          assert_equal(value, instance.send(key.to_sym), "Expected `#{key}` to be `#{value}`")
        end
      end
      
    end
  end
end


# TODO: use mocha gem instead of tweaking Net::HTTP classes
# module Net
#   class HTTP < Protocol
#     @@offline_response = nil
#     
#     class << self
#       def response()
#         r = @@offline_response ||= Marshal.load(File.read(TESTCASES_PATH + '/marshaled_response'))
#         @@offline_response = nil
#         r
#       end
#       def response=(r)
#         @@offline_response = r
#       end
#     end
#     
#     alias :request_online :request
#     def request_offline(req, body = nil, &block)
#       return self.class.response
#     end
#     
#     # prepare for offline tests
#     remove_method :request 
#     alias :request :request_offline
#   end
# end
# 
