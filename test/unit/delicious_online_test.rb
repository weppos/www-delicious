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


if TEST_REAL_TESTS
  puts "*WARNING* Running real online tests with account #{ENV['DUSERNAME']} => #{ENV['DPASSWORD']}."
else
  puts "Real online tests skipped. Set 'DUSERNAME' and 'DPASSWORD' env variables to run them."
end


class DeliciousOnlineTest < Test::Unit::TestCase
  include WWW::Delicious::TestCase
  
  def test_valid_account
    obj = instance(:username => 'foo', :password => 'bar')
    assert(!obj.valid_account?)
  end
  
  def test_update
    result = nil
    assert_nothing_raised() { result = instance.update() }
    assert_not_nil(result)
  end
  
  def test_bundles_all
    result = nil
    assert_nothing_raised() { result = instance.bundles_all() }
    assert_not_nil(result)
    result.each do |bundle|
      assert_instance_of(WWW::Delicious::Bundle, bundle)
      assert_not_nil(bundle.name)
      assert_instance_of(Array, bundle.tags)
    end
  end

end if TEST_REAL_TESTS
