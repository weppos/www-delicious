# 
# = WWW::Delicious
#
# Web service library for del.icio.us API
# 
#
# Category::   WWW
# Package::    WWW::Delicious
# Subpackage:: WWW::Delicious::Post
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id: delicious.rb 13 2008-03-15 13:03:13Z weppos $
#++


module WWW #:nodoc:
  class Delicious

    class Post
      
      # TODO: filter and validate
      attr_accessor :url, :title, :notes, :others, :uid, :tags, :time
      
      
      public
      #
      # Creates a new <tt>WWW::Delicious::Post</tt> with given values.
      # If +values_or_rexml+ is a REXML element, the element is parsed
      # and all values assigned to this instance attributes.
      #
      def initialize(values_or_rexml, &block) #  :yields: post
        case values_or_rexml
        when REXML::Element
          initialize_from_rexml(values_or_rexml)
        when Hash
          %w(url title notes others udi tags time).each do |v|
            instance_variable_set("@#{v}".to_sym(), values_or_rexml[v])
          end
        else
          raise ArgumentError, '`values_or_rexml` expected to be `Hash` or `REXML::Element`'
        end
        
        yield(self) if block_given?
        self
      end
      
      public
      #
      # Initializes <tt>WWW::Delicious::Post</tt> from a REXML fragment.
      #
      def initialize_from_rexml(element)
        self.url    = element.attribute_value(:href) { |v| URI.parse(v) }
        self.title  = element.attribute_value(:description)
        self.notes  = element.attribute_value(:extended)
        self.others = element.attribute_value(:others).to_i() # cast nil to 0
        self.uid    = element.attribute_value(:hash)
        self.tags   = element.attribute_value(:tag)  { |v| v.split(' ') }.to_a()
        self.time   = element.attribute_value(:time) { |v| Time.parse(v) }
      end
      
    end
    
  end
end
