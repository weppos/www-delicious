# 
# = WWW::Delicious
#
# Ruby client for del.icio.us API.
# 
#
# Category::    WWW
# Package::     WWW::Delicious
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
# SVN: $Id$
#++


$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'www/delicious'

# testcase file path
TESTCASES_PATH   = File.dirname(__FILE__) + '/testcases' unless defined?(TESTCASES_PATH)
FIXTURES_PATH    = File.dirname(__FILE__) + '/fixtures'  unless defined?(FIXTURES_PATH)

# prevent online tests to be run automatically
RUN_ONLINE_TESTS = (ENV['ONLINE'].to_i == 1) unless defined?(RUN_ONLINE_TESTS)


class Test::Unit::TestCase
  
  # asserts all given attributes match mapped value in +instance+.
  # +instance+ is the instance to be tested, 
  # +expected_mapping+ is the attribute => value mapping.
  def assert_attributes(instance, expected_mapping)
    expected_mapping.each do |key, value|
      assert_equal(value, instance.send(key.to_sym), "Expected `#{key}` to be `#{value}`")
    end
  end
  
end
