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


require 'www/delicious/element'


module WWW
  class Delicious

    #
    # = Delicious Bundle
    #
    # Represents a single Bundle element.
    #
    class Bundle < Element

      # The name of the bundle.
      attr_accessor :name

      # The collection of <tt>WWW::Delicious::Tags</tt>.
      attr_accessor :tags


      # Returns value for <tt>name</tt> attribute.
      # Value is always normalized as lower string.
      def name
        @name.to_s.strip unless @name.nil?
      end

      #
      # Returns a string representation of this Bundle.
      # In case name is nil this method will return an empty string.
      #
      def to_s
        name.to_s
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
            instance.name  = element.if_attribute_value(:name)
            # FIXME: value must be converted to array of Tag
            instance.tags  = element.if_attribute_value(:tags) { |value| value.split(' ') }
          end
        end

      end

    end

  end
end
