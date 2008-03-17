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
      attr_accessor :replace, :shared
      
      public
      #
      # Creates a new <tt>WWW::Delicious::Post</tt> with given values.
      # If +values_or_rexml+ is a REXML element, the element is parsed
      # and all values assigned to this instance attributes.
      #
      def initialize(values_or_rexml, &block) #  :yields: post
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
      # Initializes <tt>WWW::Delicious::Post</tt> from an +Hash+.
      #
      def initialize_from_hash(values)
        %w(url title notes others udi tags time shared replace).each do |v|
          self.instance_variable_set("@#{v}".to_sym(), values[v.to_sym()])
        end
        self.shared  = true    if self.shared.nil?
        self.replace = true    if self.replace.nil?
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
        self.shared = element.attribute_value(:shared) { |v| v == 'no' ? false : true }
      end
      
      public
      #
      # Returns a params-style representation suitable for API calls.
      #
      def to_params()
	params = {}
        params[:url] = self.url
        params[:description] = self.title
        params[:extended] = self.notes if self.notes
        params[:shared] = self.shared
        params[:tags] = self.tags.join(' ') if self.tags
        params[:replace] = self.replace
        params[:dt] = WWW::Delicious::TIME_CONVERTER.call(self.time) if self.time
        return params
      end
      
      
      public
      #
      # Returns wheter this object is valid for an API request.
      # 
      # To be valid +url+ and +title+ must not be empty.
      # 
      # === Examples
      # 
      #   post = WWW::Delicious::Post.new(:url => 'http://localhost', :title => 'foo')
      #   post.api_valid?
      #   # => true
      #
      #   post = WWW::Delicious::Post.new(:url => 'http://localhost')
      #   post.api_valid?
      #   # => false
      #
      def api_valid?
	return !(url.nil? or url.empty? or title.nil? or title.empty?)
      end
      
    end
    
  end
end
