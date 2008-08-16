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
# SVN: $Id$
#++


require 'www/delicious/element'


module WWW
  class Delicious
    
    class Post < Element
      
      # The Post URL
      attr_accessor :url
      
      # The title of the Post
      attr_accessor :title
      
      # The extended description for the Post
      attr_accessor :notes
      
      # The number of other users who saved this Post
      attr_accessor :others
      
      # The unique Id for this Post
      attr_accessor :uid
      
      # Tags for this Post
      attr_accessor :tags
      
      # Timestamp this Post was last saved at
      attr_accessor :time
      
      # Whether this Post must replace previous version of the same Post.
      attr_accessor :replace
      
      # Whether this Post is private
      attr_accessor :shared
      
      
      # Returns the value for <tt>shared</tt> attribute.
      def shared
        !(@shared == false)
      end
      
      # Returns the value for <tt>replace</tt> attribute.
      def replace
        !(@replace == false)
      end
      
      # Returns a params-style representation suitable for API calls.
      def to_params()
        params = {}
        params[:url]          = url
        params[:description]  = title
        params[:extended]     = notes if notes
        params[:shared]       = shared
        params[:tags]         = tags.join(' ') if tags.respond_to? :join
        params[:replace]      = replace
        params[:dt]           = WWW::Delicious::TIME_CONVERTER.call(time) if time
        params
      end
      
      
      #
      # Returns whether this object is valid for an API request.
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
      
      
      class << self
        
        # 
        # Creates and returns new instance from a REXML +element+.
        # 
        # Implements Element#from_rexml.
        # 
        def from_rexml(element)
          raise ArgumentError, "`element` expected to be a `REXML::Element`" unless element.kind_of? REXML::Element
          self.new do |instance|
            instance.url    = element.if_attribute_value(:href) { |v| URI.parse(v) }
            instance.title  = element.if_attribute_value(:description)
            instance.notes  = element.if_attribute_value(:extended)
            instance.others = element.if_attribute_value(:others).to_i # cast nil to 0
            instance.uid    = element.if_attribute_value(:hash)
            instance.tags   = element.if_attribute_value(:tag)  { |v| v.split(' ') }.to_a
            instance.time   = element.if_attribute_value(:time) { |v| Time.parse(v) }
            instance.shared = element.if_attribute_value(:shared) { |v| v == 'no' ? false : true }
          end
        end
        
      end
      
    end
    
  end
end
