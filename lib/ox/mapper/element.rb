# coding: utf-8

module Ox
  module Mapper
    # An element representing XML-node
    class Element
      attr_accessor :parent, :name, :text
      attr_writer :attributes

      # Initialize element with +name+
      def initialize(name)
        @name = name
      end

      def []=(k, v)
        attributes[k] = v
      end

      def [](k)
        @attributes && @attributes[k]
      end

      def attributes
        @attributes ||= {}
      end
    end # class Element
  end # module Mapper
end # module Ox