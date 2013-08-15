require 'set'
require 'ox/mapper/element'

module Ox
  module Mapper
    # Sax handler
    #
    # @api private
    class Handler
      OUTPUT_ENCODING = Encoding::UTF_8

      def initialize
        # ox supports lines and columns starting from 1.9.0
        # we just need to set these ivars
        @line, @column = nil, nil
        @stack = []
        # collected elements
        @elements_callbacks = Hash.new
        # collected attributes
        @attributes = Hash.new
      end

      # Assigns +callback+ to elements with given tag +name+
      #
      # @param [String, Symbol] name
      # @param [Proc] callback
      def setup_element_callback(name, callback)
        (@elements_callbacks[name.to_sym] ||= []) << callback.to_proc
      end

      # Collect values of attributes with given +attribute_name+
      # at elements with tag of given +tag_name+
      #
      # @param [String, Symbol] tag_name
      # @param [String, Symbol] attribute_name
      def collect_attribute(tag_name, attribute_name)
        (@attributes[tag_name.to_sym] ||= Set.new) << attribute_name.to_sym
      end

      # "start_element" handler just pushes an element to stack and assigns a pointer to parent element
      #
      # @api private
      def start_element(name)
        element = Element.new(name, @line, @column)
        element.parent = top

        @stack.push(element)
      end

      # "end_element" handler pushes an element if it is attached to callbacks
      #
      # @api private
      def end_element(*)
        element = @stack.pop

        if collect_element?(element.name)
          encode(element.text)

          @elements_callbacks[element.name].each { |cb| cb.call(element) }
        end
      end

      # attributes handler assigns attribute value to current element
      #
      # @api private
      def attr(name, value)
        top[name] = encode(value) if collect_attribute?(name)
      end

      # text handler appends given +value+ to current element +text+ attribute
      #
      # @api private
      def text(value)
        if value && top
          value.strip!

          if top.text
            top.text << encode(value)
          else
            top.text = encode(value)
          end
        end
      end
      alias cdata text

      private
      def collect_element?(element)
        element && @elements_callbacks.has_key?(element)
      end

      def collect_attribute?(name)
        top &&
        collect_element?(top.name) &&
        @attributes.has_key?(top.name) &&
        @attributes[top.name].include?(name)
      end

      # encode +str+ to utf-8
      def encode(str)
        str && !str.ascii_only? ? str.encode!(OUTPUT_ENCODING) : str
      end # def encode

      # returns top element
      def top
        @stack.last
      end
    end
  end
end