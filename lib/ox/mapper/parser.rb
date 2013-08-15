# coding: utf-8
require 'ox'
require 'ox/mapper/handler'

module Ox
  module Mapper
    # Configurable SAX-parser
    #
    # Usage:
    #   parser = Mapper.new
    #
    #   parser.on(:offer) { |offer| puts offer }
    #   parser.on(:offer => [:id]) { |v| v.to_i }
    class Parser
      def initialize
        @handler = Handler.new
      end

      # Parse given +io+ object
      def parse(io, options = {})
        Ox.sax_parse(@handler, io, options)
      end

      # Define a callbacks to be called when +elements+ processed
      #
      # @example
      #   parser.on(:offer, :price) { |elem| p elem }
      #   parser.on(:book, :attributes => [:author, :isbn]) { |book| p book[:author], book[:isbn] }
      #
      # @param [Array<String, Symbol>] elements elements names
      # @yield [element]
      # @yieldparam [Ox::Mapper::Element] element
      # @option options [Array<String, Symbol>] :attributes list of collected attributes
      def on(*elements, &block)
        options = (Hash === elements.last) ? elements.pop : {}

        attributes = Array(options[:attributes]).flatten

        elements.each do |e|
          @handler.setup_element_callback(e, block)

          attributes.each { |attr| @handler.collect_attribute(e, attr) }
        end
      end
      alias on_element on

      # Set attribute callback
      #
      # @example
      #   parser.collect_attribute(:offer => :id, 'ns:offer' => 'ns:id')
      #
      # @param [Hash{String, Symbol => String, Symbol}] map hash with element names as keys
      #                                                 and attributes names as value
      # @deprecated
      def collect_attribute(map)
        warn 'Ox::Mapper::Parser#on_attribute method is deprecated and shall be removed in future versions. '\
             'Please use #on(element_name, :attributes => [...]) notation.'

        map.each_pair do |k, attributes|
          Array(attributes).flatten.each { |attr| @handler.collect_attribute(k, attr) }
        end
      end
      alias on_attribute collect_attribute
    end # class Parser
  end # module Mapper
end # module Ox
