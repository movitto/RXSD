# tests the xml modules
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe "RXSD::XML" do

   it "should provide root node given adapter and xml data" do
      root_node = XML::Node.factory :backend => :libxml, :xml => "<schema/>"
      root_node.is_a?(XML::LibXMLNode).should be_true
   end

   it "should return correct root node" do
       child = MockXMLNode.new
       parent = MockXMLNode.new
       gp = MockXMLNode.new

       child.root.should == child
       child.test_parent = parent
       child.root.should == parent
       parent.root.should == parent
       parent.test_parent = gp
       child.root.should == gp
       parent.root.should == gp
   end

   it "should instantiate all children of a specified class type from xml" do
       child1 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child2 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child3 = MockXMLNode.new :name => "foobar"
       parent = MockXMLNode.new
       parent.children << child1 << child2 << child3

       children = parent.children_objs(MockXMLEntity)
       children.size.should == 2
       children[0].class.should == MockXMLEntity
       children[1].class.should == MockXMLEntity
   end

   it "should return value attributes of all children w/ specified name" do
       child1 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child2 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child3 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child4 = MockXMLNode.new :name => "foobar"
       parent = MockXMLNode.new
       parent.children << child1 << child2 << child3

       children = parent.child_values(MockXMLEntity.tag_name)
       children.size.should == 3
       children[0].should == 'pi'
       children[1].should == 'pi'
       children[2].should == 'pi'
   end

end

describe "RXSD::LibXMLAdapter" do

   before(:each) do
      @test_xml = 
       "<schema xmlns:h='http://test.host/ns.xml' xmlns:a='aaa' >" + 
         "<entity some_attr='foo' another_attr='bar'><child child_attr='123' /></entity>" + 
         "<other_entity>some text</other_entity>" + 
       "</schema>"
   end

   it "should parse xml children" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      root.children.size.should == 2
      root.children.each    { |c| c.class.should == XML::LibXMLNode }
      root.children.collect { |c| c.name }.include?("entity").should be_true
      root.children.collect { |c| c.name }.include?("other_entity").should be_true
      root.children.collect { |c| c.name }.include?("foo_entity").should be_false

      root.children[0].children.size.should == 1
      root.children[1].children.size.should == 0
   end

   it "should parse xml names" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      root.name.should == "schema"
      root.children[0].name.should == "entity"
      root.children[1].name.should == "other_entity"
      root.children[0].children[0].name.should == "child"
   end

   it "should parse xml attributes" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      root.children[0].attrs.should == {'some_attr' => 'foo', 'another_attr' => 'bar'}
      root.children[0].children[0].attrs.should == {'child_attr' => '123' }
   end

   it "should identify and return parent" do
      root = XML::LibXMLNode.xml_root(@test_xml)

      root.parent?.should be_false
      root.parent.should be_nil

      root.children[0].parent?.should be_true
      root.children[0].parent.should == root

      root.children[1].parent?.should be_true
      root.children[1].parent.should == root

      root.children[0].children[0].parent?.should be_true
      root.children[0].children[0].parent.should == root.children[0]
   end

   it "should identify text and return content" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      root.children[0].text?.should be_false
      root.children[1].text?.should be_true
      root.children[0].children[0].text?.should be_false

      root.children[1].content.should  == "some text"
   end

   it "should return namespaces" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      root.namespaces.size.should == 2
      root.namespaces.collect { |ns| ns.to_s }.include?('h:http://test.host/ns.xml').should be_true
      #root.children[0].namespaces.size.should == 0 # children share the namespace apparently
   end

end


class MockXMLEntity
   def self.tag_name
      "mock_xml_entity"
   end

   def self.from_xml(node)
      MockXMLEntity.new
   end
end

class MockXMLNode < XML::Node
   attr_accessor :tag_name

   attr_accessor :test_attrs

   attr_accessor :test_parent

   attr_accessor :test_children

   def initialize(args = {})
     @tag_name = args[:name] if args.has_key? :name

     @test_parent = nil
     @test_children = []
     @test_children += args[:children] if args.has_key? :children
   end

   def name
     @tag_name
   end
 
   def attrs
      {:str_attr => "foobar", :int_attr => 50, :float_attr => 1.2, 'value' => 'pi'}
   end

   def parent?
      !@test_parent.nil?
   end

   def parent
      @test_parent
   end

   def children
      @test_children
   end

   def text?
      false
   end

   def content
      "contents"
   end

   def namespaces 
      []
   end
end

