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


# Require helper file
require File.dirname(__FILE__) + '/helper'

# Load and run all tests
Dir.glob(File.dirname(__FILE__) + '/unit/**/*_test.rb') do |filename| 
  puts "Loaded file #{filename}"
  load filename
end
