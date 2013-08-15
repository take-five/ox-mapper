# coding: utf-8

require 'spec_helper'
require 'ox/mapper/parser'
require 'stringio'

describe Ox::Mapper::Parser do
  let(:parser) { Ox::Mapper::Parser.new }
  let :xml do
    StringIO.new <<-XML
<xml>
  <offer id="1" id2="0">
    <price value="1"/>
  </offer>
  <offer id="2" id2="0">
    <price value="2"/>
  </offer>
  <text>text</text>
  <text>
    <![CDATA[
    text
    ]]>
  </text>
  <ns:offer ns:id="3" />
</xml>
    XML
  end

  describe '#on' do
    let(:elements) { [] }

    context 'when one element given' do
      before { parser.on(:offer) { |e| elements << e } }
      before { parser.parse(xml) }

      it 'should execute given block on each given element' do
        elements.should have(2).items
      end
    end

    context 'when multiple elements given' do
      before do
        parser.on :offer,
                  :price,
                  'ns:offer',
                  :attributes => [:id, :value, 'ns:id'] do |e|
          elements << e
        end
      end
      before { parser.parse(xml) }

      subject { elements }

      it { should have(5).items }

      it 'should collect elements in ascending order (starting from leafs to root)' do
        elements[0].name.should eq :price
        elements[0][:value].should eq '1'

        elements[1].name.should eq :offer
        elements[1][:id].should eq '1'

        elements[2].name.should eq :price
        elements[2][:value].should eq '2'

        elements[3].name.should eq :offer
        elements[3][:id].should eq '2'

        elements[4]['ns:id'].should eq '3'
      end

      it 'should collect parent element' do
        elements[0].parent.should be elements[1]
        elements[1].parent.name.should eq :xml
      end
    end
  end

  describe 'parsing element contents' do
    let(:elements) { [] }
    before { parser.on_element(:text) { |e| elements << e.text } }
    before { parser.parse(xml) }

    subject { elements }

    it { should have(2).items }
    it { should eq %w(text text) }
  end
end