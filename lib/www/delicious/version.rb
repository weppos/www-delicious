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
#
#++


module WWW
  class Delicious

    module Version
      MAJOR = 0
      MINOR = 3
      TINY  = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end

    VERSION         = Version::STRING
    STATUS          = 'beta'
    BUILD           = ''.match(/(\d+)/).to_a.first

  end
end
