require 'ox'
require 'ox/mapper/handler'
require 'oj'

module Ox
  module Mapper
    class DSL
      def initialize
        @handler = Handler.new

        @stack = []
      end

      # Parse given +io+ object
      def parse(io, options = {})
        Ox.sax_parse(@handler, io, options)
      end

      def element(name, options = {}, &block)
        @handler.setup_element_callback(name, :start) do |element|
          @stack.push(element)
        end

        @handler.setup_element_callback(name, :end) do |element|
          @stack.pop

          top = @stack.last

          if top
            top[element.name] = block_given? ? element : element.text
          else
            #p element
            puts Oj.dump(element.attributes, :mode => :compat)
          end
        end

        instance_eval(&block) if block_given?
      end
    end # class DSL
  end # module Mapper
end # module Ox