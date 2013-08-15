# Ox::Mapper

Ox::Mapper's intention is to simplify creation of parsers based on [`ox`](https://github.com/ohler55/ox)

## Installation

Add this line to your application's Gemfile:

    gem 'ox-mapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ox-mapper

## Usage

All you need to do is to setup callbacks for elements and attributes in Ruby style
```ruby
mapper = Ox::Mapper.new

mapper.on(:book) { |book| puts book.attributes.inspect }
mapper.on(:title) { |title| title.parent[:title] = title.text }

# collected attributes should be set up explicitely
mapper.on(:author, :attributes => :name) { |e| e.parent[:author] = e[:name] }

# setup transformation for attribute "value" of "price" element
mapper.on(:price, :attributes => :value) { |e| e.parent[:price] = Float(e[:value]) }

mapper.parse(StringIO.new <<-XML) # => {:title => "Serenity", :author => "John Dow", :price => 1123.0}
  <xml>
    <book>
      <title>Serenity</title>
      <author name="John Dow" age="99" />
      <price value="1123" />
    </book>
  </xml>
XML
```

This API is unstable and a subject to change.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
