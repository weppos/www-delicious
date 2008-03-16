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
      attr_reader :name
      
      # The number of links tagged with this tag.
      # It should be set only from an API response.
      attr_reader :count
      
      
      public
      #
      # Creates a new <tt>WWW::Delicious::Tag</tt> with given +name+.
      #
      def initialize(name_or_rexml, &block) #  :yields: tag
        case name_or_rexml
        when REXML::Element
          initialize_from_rexml(name_or_rexml)
        else
          self.name  = name_or_rexml.to_s()
          self.count = 0
        end
        
        yield(self) if block_given?
        self
      end
      
      public
      #
      # Initializes <tt>WWW::Delicious::Tag</tt> from a REXML fragment.
      #
      def initialize_from_rexml(element)
        self.name  = element.attribute_value(:tag)
        self.count = element.attribute_value(:count).to_i()
      end
      
      
      public
      #
      # Sets +name+ for this instance to given +value+.
      # +value+ is always cast to a +String+.
      # 
      def name=(value)
	@name = value.to_s()
      end
      
      public
      #
      # Sets +count+ for this instance to given +value+.
      # +value+ is always cast to +Integer+.
      # 
      def count=(value)
	@count = value.to_i()
      end
      
      public
      #
      # Returns a string representation of this Tag.
      #
      def to_s()
	return self.name
      end
      
      
    end
    
  end
end
