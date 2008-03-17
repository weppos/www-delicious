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
      # Creates a new <tt>WWW::Delicious::Tag</tt>.
      #
      def initialize(values_or_rexml, &block) # :yields: tag
        case values_or_rexml
        when Hash
          initialize_from_hash(values_or_rexml)
        when REXML::Element
          initialize_from_rexml(values_or_rexml)
        else
          raise ArgumentError, 'Expected `values_or_rexml` to be `Hash` or `REXML::Element`'
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
        self.count = element.attribute_value(:count)
      end
      
      public
      #
      # Initializes <tt>WWW::Delicious::Tag</tt> from an Hash.
      #
      def initialize_from_hash(values)
        self.name  = values[:name]
        self.count = values[:count]
      end
      
      
      public
      #
      # Sets +name+ for this instance to given +value+.
      # +value+ is always cast to a +String+.
      # 
      # Leading and trailing whitespaces are stripped.
      #
      def name=(value)
	@name = value.to_s().strip()
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
      
    end
    
  end
end
