# coding: utf-8

module Ox
  module Mapper
    # An element representing XML-node
    #
    # @api private
    class Element
      attr_accessor :parent, :name, :text, :line, :column
      attr_writer :attributes

      # Initialize element with +name+
      #
      # @param [Symbol] name
      # @param [Integer] line
      # @param [Integer] column
      def initialize(name, line = nil, column = nil)
        @name, @line, @column = name, line, column
      end

      # Set element attribute
      #
      # @param [Symbol, String] name attribute name
      # @param [Object] value attribute value
      def []=(name, value)
        attributes[name] = value
      end

      # Get attribute value
      #
      # @param [Symbol, String] name attribute name
      # @return [Object] attribute value
      def [](name)
        @attributes && @attributes[name.to_sym]
      end

      # Get attributes hash
      #
      # @return [Hash] attributes
      def attributes
        @attributes ||= {}
      end
    end # class Element
  end # module Mapper
end # module Ox