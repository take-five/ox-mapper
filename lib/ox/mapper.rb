# coding: utf-8
require 'ox/mapper/version'

module Ox
  # Ox::Mapper's intention is to simplify usage of Ox::Sax parsers
  # All you need to do is to setup callbacks for elements and attributes in Ruby style
  #
  # Example:
  #   mapper = Ox::Mapper.new
  #   mapper.on(:book) { |e| puts book.attributes.inspect }
  #   mapper.on(:title) { |e| e.parent[:title] = e.text }
  #   mapper.on(:author, :attributes => :name) { |e| e.parent[:author] = e[:name] }
  #   mapper.on_element(:price, :attributes => :value) { |e| e.parent[:price] = Float(e[:value]) }
  #
  #   mapper.parse(StringIO.new <<-XML) # => {:title => "Serenity", :author => "John Dow", :price => 1123.0}
  #     <xml>
  #       <book>
  #         <title>Serenity</title>
  #         <author name="John Dow" />
  #         <price value="1123" />
  #       </book>
  #     </xml>
  #   XML
  module Mapper
    autoload :Parser, 'ox/mapper/parser'

    def self.new
      Parser.new
    end
  end # module Mapper
end