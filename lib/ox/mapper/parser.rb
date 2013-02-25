# coding: utf-8
require "ox"
require "ox/mapper/element"

begin
  require "cstack"
rescue LoadError
  require "rubystack"
end

module Ox
  module Mapper
    # Configurable SAX-parser
    #
    # Usage:
    #   parser = Mapper.new
    #
    #   parser.on_element(:offer) { |offer| puts offer }
    #   parser.on_attribute(:offer => [:id]) { |v| v.to_i }
    class Parser < Ox::Sax
      OUTPUT_ENCODING = Encoding::UTF_8

      def initialize
        @stack = CStack.new
        @callbacks = Hash.new { |h, k| h[k] = [] }
        @attribute_callbacks = Hash.new
      end

      # Parse given +io+ object
      def parse(io, options = {})
        Ox.sax_parse(self, io, options)
      end

      # Define a callbacks to be called when +elements+ processed
      #
      # Usage:
      #   parser.on_element(:offer, :price) { |elem| p elem }
      def on_element(*elements, &block)
        elements.each { |e| @callbacks[e] << block }
      end

      # Usage:
      #   parser.on_attribute(:offer => :price) { |p| Float(p) }
      def on_attribute(map, &block)
        map.each_pair do |k, attributes|
          @attribute_callbacks[k] ||= Hash.new
          [attributes].flatten.each { |attr| @attribute_callbacks[k][attr] = block }
        end
      end
      alias collect_attribute on_attribute

      # "start_element" handler just pushes an element to stack and assigns a pointer to parent element
      # @api private
      def start_element(name) #:nodoc:
        element = Ox::Mapper::Element.new(name)
        element.parent = @stack.top

        @stack.push(element)
      end

      # attributes handler
      # @api private
      def attr(name, value) #:nodoc:
        @stack.top[name] = transform_attribute(name, value) if collect_attribute?(name)
      end

      # @api private
      def text(value) #:nodoc:
        @stack.top.text = value if @stack.size > 0
      end

      # "end_element" handler pushes an element if it is attached to callbacks
      # @api private
      def end_element(name) #:nodoc:
        element = @stack.pop

        # fire callback
        if @callbacks.has_key?(element.name)
          element.text.encode!("UTF-8") if element.text && !element.text.ascii_only?

          @callbacks[element.name].each { |cb| cb.call(element) }
        end
      end

      private
      def collect_attribute?(name) #:nodoc:
        top_name = @stack.size > 0 && @stack.top.name

        top_name &&
            @attribute_callbacks.key?(top_name) &&
            @attribute_callbacks[top_name].key?(name)
      end

      # Fetch callback for attribute +name+
      def attribute_callback(name) #:nodoc:
        @attribute_callbacks[@stack.top.name][name]
      end

      # Apply callback to attribute or just transcode +value+ if callback is empty
      def transform_attribute(name, value) #:nodoc:
        if (proc = attribute_callback(name))
          proc[value]
        else
          encode(value)
        end
      end

      # encode +str+ to utf-8
      def encode(str) #:nodoc:
        str && !str.ascii_only? ? str.encode!(OUTPUT_ENCODING) : str
      end # def encode

    end # class Mapper
  end
end
