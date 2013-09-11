require 'set'
require 'ox/mapper/element'

module Ox
  module Mapper
    # Sax handler
    #
    # @api private
    class Handler
      OUTPUT_ENCODING = Encoding::UTF_8

      class CallbackChain
        def initialize
          @callbacks = {:start => [], :end => []}
        end

        def append(kind, callback)
          @callbacks[kind] << callback.to_proc
        end

        def any?(kind)
          @callbacks[kind].any?
        end

        def empty?(kind)
          @callbacks[kind].empty?
        end

        def call(kind, *args)
          @callbacks[kind].each { |cb| cb.call(*args) }
        end
      end

      def initialize
        # ox supports lines and columns starting from 1.9.0
        # we just need to set these ivars
        @line, @column = nil, nil
        @stack = []
        # collected elements
        @elements_callbacks = Hash.new { |h, k| h[k] = CallbackChain.new }
        # collected attributes
        @attributes = Hash.new { |h, k| h[k] = Set.new }
      end

      # Assigns +callback+ to elements with given tag +name+
      #
      # @param [String, Symbol] name
      # @param [:start, :end] kind callback kind
      # @param [Proc] callback
      def setup_element_callback(name, kind, callback = nil, &block)
        @elements_callbacks[name.to_sym].append(kind, callback || block)
      end

      # Collect values of attributes with given +attribute_name+
      # at elements with tag of given +tag_name+
      #
      # @param [String, Symbol] tag_name
      # @param [String, Symbol] attribute_name
      def collect_attribute(tag_name, attribute_name)
        @attributes[tag_name.to_sym] << attribute_name.to_sym
      end

      # "start_element" handler just pushes an element to stack and assigns a pointer to parent element
      #
      # @api private
      def start_element(name)
        element = Element.new(name, @line, @column)

        @stack.push(element)

        fire_callback(element.name, :start, element)
      end

      # "end_element" handler pushes an element if it is attached to callbacks
      #
      # @api private
      def end_element(*)
        element = @stack.pop

        if collect_element?(element.name)
          encode(element.text)

          fire_callback(element.name, :end, element)
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
        if value && top && collect_element?(top.name)
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
        element &&
          @elements_callbacks.key?(element) &&
          @elements_callbacks[element].any?(:end)
      end

      def collect_attribute?(name)
        top &&
        collect_element?(top.name) &&
        @attributes.key?(top.name) &&
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

      def fire_callback(name, kind, *args)
        @elements_callbacks[name].call(kind, *args) if @elements_callbacks.has_key?(name)
      end
    end
  end
end