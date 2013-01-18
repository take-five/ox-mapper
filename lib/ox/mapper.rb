require "ox/mapper/version"

module Ox
  # Ox::Mapper's intention is to simplify usage of Ox::Sax parsers
  # All you need to do is to setup callbacks for elements and attributes in Ruby style
  #
  # Example:
  #   mapper = Ox::Mapper.new
  #   mapper.on_element(:book) { |e| puts book.attributes.inspect }
  #   mapper.on_element(:title) { |e| e.parent[:title] = e.text }
  #
  #   mapper.collect_attribute(:author => :name)
  #   mapper.on_element(:author) { |e| e.parent[:author] = e[:name] }
  #
  #   # setup transformation for attribute "value" of "price" element
  #   mapper.on_attribute(:price => :value) { |v| Float(v) }
  #   mapper.on_element(:price) { |e| e.parent[:price] = e[:value] }
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
    autoload :Parser, "ox/mapper/parser"

    def self.new
      Parser.new
    end
  end # module Mapper
end