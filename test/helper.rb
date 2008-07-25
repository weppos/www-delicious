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
TESTCASE_PATH   = File.dirname(__FILE__) + '/testcases' unless defined?(TESTCASE_PATH)

# prevent online tests to be run automatically
RUN_ONLINE_TESTS = (ENV['ONLINE'] == "1") unless defined? RUN_ONLINE_TESTS


# TODO: use mocha gem instead of tweaking Net::HTTP classes
# module Net
#   class HTTP < Protocol
#     @@offline_response = nil
#     
#     class << self
#       def response()
#         r = @@offline_response ||= Marshal.load(File.read(TESTCASE_PATH + '/marshaled_response'))
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
