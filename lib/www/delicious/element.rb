# 
# = WWW::Delicious
#
# Ruby client for del.icio.us API.
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Subpackage:: WWW::Delicious::Post
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id$
#++


module WWW
  class Delicious

    # 
    # = Abstract structure
    # 
    # Represent the most basic structure all Struc(s) must inherith from.
    # 
    class Element
      
      #
      # Initializes a new instance and populate attributes from +attrs+.
      # 
      #   class User < Element
      #     attr_accessor :first_name
      #     attr_accessor :last_name
      #   end
      # 
      #   User.new
      #   User.new(:first_name => 'foo')
      #   User.new(:first_name => 'John', :last_name => 'Doe')
      # 
      # You can even use a block.
      # The following statements are equals:
      # 
      #   User.new(:first_name => 'John', :last_name => 'Doe')
      # 
      #   User.new do |user|
      #     user.first_name => 'John'
      #     user.last_name  => 'Doe'
      #   end
      # 
      # Warning. In order to set an attribute a valid attribute writer must be available,
      # otherwise this method will raise an exception.
      #
      def initialize(attrs = {}, &block)
        attrs.each { |key, value| self.send("#{key}=".to_sym, value) }
        yield self if block_given?
        self
      end
      
      class << self
        
        # 
        # Creates and returns new instance from a REXML +element+.
        # 
        def from_rexml(element, options)
          raise NotImplementedError
        end
        
      end
      
    end
    
  end
end
