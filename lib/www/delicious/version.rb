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
      MINOR = 4
      PATCH = 0
      BUILD = nil

      STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join(".")
    end

    VERSION = Version::STRING

  end
end
