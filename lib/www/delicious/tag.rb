# 
# = WWW::Delicious
#
# Ruby client for del.icio.us API.
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Subpackage:: WWW::Delicious::Tag
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id$
#++


require 'www/delicious/element'


module WWW
  class Delicious

    #
    # = Delicious Tag
    # 
    # Represents a single Tag element.
    #
    class Tag < Element
      
      # The name of the tag.
      attr_accessor :name
      
      # The number of links tagged with this tag.
      # It should be set only from an API response.
      attr_accessor :count
      
      
      # Returns value for <tt>name</tt> attribute.
      # Value is always normalized as lower string.
      def name
        @name.to_s.strip unless @name.nil?
      end
      
      # Returns value for <tt>count</tt> attribute.
      # Value is always normalized to Fixnum.
      def count
        @count.to_i
      end
      
      #
      # Returns a string representation of this Tag.
      # In case name is nil this method will return an empty string.
      #
      def to_s
        name.to_s
      end
      
      
      public
      #
      # Returns wheter this object is valid for an API request.
      # 
      # To be valid +name+ must not be empty.
      # +count+ can be 0.
      # 
      # === Examples
      # 
      #   tag = WWW::Delicious::Tag.new(:name => 'foo')
      #   tag.api_api_valid?
      #   # => true
      #
      #   tag = WWW::Delicious::Tag.new(:name => '  ')
      #   tag.api_api_valid?
      #   # => false
      #
      def api_valid?
        return !name.empty?
      end
      
      
      class << self
        
        # 
        # Creates and returns new instance from a REXML +element+.
        # 
        # Implements Element#from_rexml.
        # 
        def from_rexml(element)
          raise ArgumentError, "`element` expected to be a `REXML::Element`" unless element.kind_of? REXML::Element
          self.new do |instance|
            instance.name  = element.if_attribute_value(:tag)
            instance.count = element.if_attribute_value(:count) { |value| value.to_i }
          end
        end
        
      end
      
    end
    
  end
end
