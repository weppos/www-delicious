# 
# = WWW::Delicious
#
# Web service library for del.icio.us API
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Subpackage:: WWW::Delicious::Tag
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id: delicious.rb 13 2008-03-15 13:03:13Z weppos $
#++


module WWW #:nodoc:
  class Delicious

    class Tag
      
      # The name of the tag
      attr_accessor :name
      # The number of links tagged with this tag.
      # It should be set only from an API response.
      attr_accessor :count
      
      
      public
      #
      # Creates a new <tt>WWW::Delicious::Tag</tt> with given +name+.
      #
      def initialize(name_or_rexml, &block) #  :yields: tag
        case name_or_rexml
        when REXML::Element
          initialize_from_rexml(name_or_rexml)
        else
          self.name = name_or_rexml.to_s()
        end
        
        yield(self) if block_given?
        self
      end
      
      public
      #
      # Initializes <tt>WWW::Delicious::Tag</tt> from a REXML fragment.
      #
      def initialize_from_rexml(element)
        self.name  = element.attribute_value(:tag)  { |v| v.to_s() }
        self.count = element.attribute_value(:count) { |v| v.to_i() }
      end
      
    end
    
  end
end
