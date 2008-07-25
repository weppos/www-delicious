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


RUN_ONLINE_TESTS = true

require  File.dirname(__FILE__) + '/helper'
Dir.glob(File.dirname(__FILE__) + '/unit/**/*_test.rb').sort.each { |unit| require unit }
