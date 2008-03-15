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
# SVN: $Id: delicious_test.rb 13 2008-03-15 13:03:13Z weppos $
#++


require File.dirname(__FILE__) + '/../helper'


class DeliciousOnlineTest < Test::Unit::TestCase
  
  def test_valid_account
    obj = instance(:username => 'foo', :password => 'bar')
    assert(!obj.valid_account?)
  end
  
  def test_update
    result = nil
    assert_nothing_raised() { result = instance.update() }
    assert_not_nil(result)
  end

end if 1 == 2 # disable for now
