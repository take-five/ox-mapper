# coding: utf-8

require "spec_helper"
require "ox/mapper/parser"
require "stringio"

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
</xml>
    XML
  end

  describe "#on_element" do
    let(:elements) { [] }

    context "when one element given" do
      before { parser.on_element(:offer) { |e| elements << e } }
      before { parser.parse(xml) }

      it "should execute given block on each given element" do
        elements.should have(2).items
      end
    end

    context "when multiple elements given" do
      before { parser.on_element(:offer, :price) { |e| elements << e } }
      before { parser.collect_attribute(:offer => :id, :price => :value) }
      before { parser.parse(xml) }

      subject { elements }

      it { should have(4).items }

      it "should collect elements in ascending order (starting from leafs to root)" do
        elements[0].name.should eq :price
        elements[0][:value].should eq "1"

        elements[1].name.should eq :offer
        elements[1][:id].should eq "1"

        elements[2].name.should eq :price
        elements[2][:value].should eq "2"

        elements[3].name.should eq :offer
        elements[3][:id].should eq "2"
      end

      it "should collect parent element" do
        elements[0].parent.should be elements[1]
        elements[1].parent.name.should eq :xml
      end
    end
  end

  describe "#on_attribute" do
    let(:elements) { [] }
    before { parser.on_element(:offer) { |e| elements << e } }

    subject { elements[0] }

    context "when no block given" do
      before { parser.collect_attribute(:offer => :id) }
      before { parser.parse(xml) }

      its([:id]) { should eq "1" }
      its(:attributes) { should_not have_key(:id2) }
    end

    context "when block given" do
      before { parser.on_attribute(:offer => [:id, :id2]) { |v| Float(v) } }
      before { parser.parse(xml) }

      its([:id]) { should eq 1.0 }
      its([:id2]) { should eq 0.0 }
    end
  end
end