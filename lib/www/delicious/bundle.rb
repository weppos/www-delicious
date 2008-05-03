# 
# = WWW::Delicious
#
# Ruby client for del.icio.us API.
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Subpackage:: WWW::Delicious::Bundle
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id$
#++


module WWW #:nodoc:
  class Delicious

    class Bundle
      
      # The name of the bundle
      attr_accessor :name
      
      # The collection of <tt>WWW::Delicious::Tags</tt>
      attr_accessor :tags
      
      public
      #
      # Creates a new <tt>WWW::Delicious::Bundle</tt> with given +name+
      # and adds given array of +tags+ to current tags collection.
      #
      def initialize(name, tags = [], &block) #  :yields: bundle
        raise ArgumentError, '`tags` expected to be an Array' unless tags.kind_of?(Array)
        
        self.name = name.to_s()
        self.tags = tags
        yield(self) if block_given?
        self
      end
      
      public
      #
      # Creates a new <tt>WWW::Delicious::Bundle</tt> from a REXML fragment.
      #
      def self.from_rexml(element)
        return new(element.attribute_value(:name) { |v| v.to_s() },
                   element.attribute_value(:tags) { |v| v.to_s().split(' ') })
      end
      
    end
    
  end
end
