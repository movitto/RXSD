# tests the parser module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe "Parser" do

  it "should  parse xsd" do
     File.write("/tmp/rxsd-test", "<schema><element name='foo' type='xs:boolean' />" + 
                                  "<complexType><choice><element ref='foo' /></choice></complexType></schema>")
     schema = Parser.parse_xsd :uri => "file:///tmp/rxsd-test"
     schema.elements.size.should == 1
     schema.complex_types.size.should == 1
     schema.elements[0].name.should == "foo"
     schema.elements[0].type.should == Boolean
     schema.complex_types[0].choice.elements[0].ref.name.should == "foo"
     schema.complex_types[0].choice.elements[0].ref.type.should == Boolean
  end

  it "should identifity builtin types" do
     Parser.is_builtin?(String).should == true
     Parser.is_builtin?(Boolean).should == true
     Parser.is_builtin?(XSDFloat).should == true
     Parser.is_builtin?(XSDInteger).should == true
     !Parser.is_builtin?(Parser).should == true
  end

  it "should parse builtin types" do
     Parser.parse_builtin_type("xs:string").should == String
     Parser.parse_builtin_type("xs:boolean").should == Boolean
     Parser.parse_builtin_type("xs:decimal").should == XSDFloat
     Parser.parse_builtin_type("xs:float").should == XSDFloat
     Parser.parse_builtin_type("xs:double").should == XSDFloat
  end

  it "should parse schema" do
     data = "<schema version='4.20' targetNamespace='foobar' xmlns='http://www.w3.org/2001/XMLSchema' xmlns:foo='http://morsi.org/myschema' " +
            "   elementFormDefault='qualified' attributeFormDefault='unqualified' />"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     schema.namespaces.size.should == 2
     schema.targetNamespace.should == 'foobar'
     schema.namespaces[nil].should == 'http://www.w3.org/2001/XMLSchema'
     schema.namespaces['foo'].should == 'http://morsi.org/myschema'
     schema.elementFormDefault.should == "qualified"
     schema.attributeFormDefault.should == "unqualified"

     data = "<schema><element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     schema.elements.size.should == 1
     schema.elements[0].id.should == "foo"

     data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'><xs:element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     schema.elements.size.should == 1
     schema.elements[0].id.should == "foo"
  end

  it "should parse element" do
     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:element id="iii" name="xxx" type="yyy" default="Foobar" maxOccurs="5" '+
                 ' nillable="true" abstract="true" ref="Foo" form="qualified" />' +
            '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0], 
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     element.id.should == "iii"
     element.name.should == "xxx"
     element.type.should == "yyy"
     element.default.should == nil
     element.maxOccurs.should == 5
     element.minOccurs.should == 1
     element.nillable.should == true
     element.abstract.should == true
     element.ref.should == "Foo"
     element.form.should == "qualified"

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
                '<xs:element default="Foobar" minOccurs="unbounded">' +
                   '<Foo/>' +
                '</xs:element>' +
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     element.default.should == nil
     element.minOccurs.should == "unbounded"

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="unqualified">'+
                '<xs:element id="iii" ref="Foo" />'+
             '</schema>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     element.id.should == "iii"
     element.ref.should == nil
     element.form.should == "unqualified"

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
              '<xs:element default="Foobar" minOccurs="unbounded">' +
                '<simpleType id="foobar"/>' +
              '</xs:element>'+
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     element.default.should == "Foobar"
     element.simple_type.id.should == "foobar"
  end

  it "should parse complex type" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="iii" name="xxx" abstract="true" mixed="true">' +
                 '<xs:attribute name="Foo" />' +
                 '<xs:attribute name="Bar" />' +
                 '<xs:group name="Gr" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     complexType.id.should == "iii"
     complexType.name.should == "xxx"
     complexType.abstract.should == true
     complexType.mixed.should == true
     complexType.attributes.size.should == 2
     complexType.attributes[0].name.should == "Foo"
     complexType.attributes[1].name.should == "Bar"
     complexType.group.name.should == "Gr"

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType mixed="true">' +
                 '<xs:simpleContent id="123" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     complexType.mixed.should == false
     complexType.simple_content.id.should == "123"
  end

  it "should parse simple type" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="iii" name="xxx">' +
                 '<xs:restriction id="rs1" />' +
                 '<xs:list id="li1" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     simpleType = SimpleType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     simpleType.id.should == "iii"
     simpleType.name.should == "xxx"
     simpleType.restriction.id.should == "rs1"
     simpleType.list.id.should == "li1"
  end

  it "should parse attribute" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attribute id="at1" name="at1" use="optional" form="qualified" default="123" type="foo" />' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     attr.id.should == "at1"
     attr.name.should == "at1"
     attr.form.should == "qualified"
     attr.default.should == "123"
     attr.type.should == "foo"
     attr.simple_type.should == nil

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" attributeFormDefault="unqualified" >' +
               '<xs:attribute id="at2" fixed="123" type="foo">' +
                 '<xs:simpleType id="st1" />' +
               '</xs:attribute>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     attr.id.should == "at2"
     attr.form.should == "unqualified"
     attr.type.should == nil
     attr.simple_type.should_not be_nil
     attr.simple_type.id.should == "st1"
  end

  it "should parse attribute group" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attributeGroup id="ag1" name="ag1" ref="ag2">' +
                  '<xs:attribute id="a1" />' +
                  '<xs:attribute id="a2" />' +
                  '<xs:attributeGroup id="ag3" />' +
               '</xs:attributeGroup>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attrGroup = AttributeGroup.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     attrGroup.id.should == "ag1"
     attrGroup.name.should == "ag1"
     attrGroup.ref.should == "ag2"
     attrGroup.attributes.size.should == 2
     attrGroup.attribute_groups.size.should == 1
     attrGroup.attributes[0].id.should == "a1"
     attrGroup.attributes[1].id.should == "a2"
     attrGroup.attribute_groups[0].id.should == "ag3"
  end

  it "should parse group" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g1" name="g1" maxOccurs="5" minOccurs="unbounded">' +
                  '<xs:choice id="c1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     group.id.should == "g1"
     group.name.should == "g1"
     group.maxOccurs.should == 5
     group.minOccurs.should == "unbounded"
     group.choice.id.should == "c1"

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g2" ref="g1" >'+
                  '<xs:sequence id="s1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     group.ref.should == "g1"
     group.minOccurs.should == 1
     group.maxOccurs.should == 1
     group.sequence.id.should == "s1"
  end

  it "should parse list" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo">' +
                   '<xs:simpleType id="st2" />' +
                 '</xs:list>' + 
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     list.id.should == "li1"
     list.itemType.should == nil
     list.simple_type.id.should == "st2"

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     list.itemType.should == "Foo"
  end

  it "should parse simple content" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:simpleContent id="sc1">' +
                 '  <xs:restriction id="r1" />' +
                 '</xs:simpleContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     simple_content = SimpleContent.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     simple_content.id.should == "sc1"
     simple_content.restriction.id.should == "r1"
  end

  it "should parse choice" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:choice id="c1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element id="e2" />' +
                 '  <xs:element id="e3" />' +
                 '  <xs:choice id="c2" />' +
                 '  <xs:choice id="c3" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     choice = Choice.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root ))))
     choice.id.should == "c1"
     choice.maxOccurs.should == 5
     choice.minOccurs.should == "unbounded"
     choice.elements.size.should == 3
     choice.elements[1].id.should == "e2"
     choice.choices.size.should == 2
     choice.choices[0].id.should == "c2"

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:choice id="c1" >'+
                 '  <xs:sequence id="s1" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     choice = Choice.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     choice.maxOccurs.should == 1
     choice.minOccurs.should == 1
     choice.sequences.size.should == 1
     choice.sequences[0].id.should == "s1"
  end

  it "should parse complex content" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:restriction id="r1"/>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexContent = ComplexContent.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     complexContent.id.should == "cc1"
     complexContent.mixed.should == true
     complexContent.restriction.id.should == "r1"
  end

  it "should parse sequence" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:sequence id="s1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element id="e2" />' +
                 '  <xs:element id="e3" />' +
                 '  <xs:choice id="c2" />' +
                 '  <xs:choice id="c3" />' +
                 '</xs:sequence>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     seq = Sequence.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root ))))
     seq.id.should == "s1"
     seq.maxOccurs.should == 5
     seq.minOccurs.should == "unbounded"
     seq.elements.size.should == 3
     seq.elements[1].id.should == "e2"
     seq.choices.size.should == 2
     seq.choices[0].id.should == "c2"
  end

  it "should parse extension" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:extension id="e1" base="Foo">' +
                        '<xs:group id="g1" />' +
                        '<xs:attribute id="a1" />' +
                        '<xs:attribute id="a2" />' +
                    '</xs:extension>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     ext = Extension.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))))
     ext.id.should == "e1"
     ext.base.should == "Foo"
     ext.group.id.should == "g1"
     ext.attributes.size.should == 2
     ext.attributes[0].id.should == "a1"
  end

  it "should parse restriction" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:restriction id="r1" base="xs:integer">' +
                        '<xs:attributeGroup id="ag1" />' +
                        '<xs:attributeGroup id="ag2" />' +
                        '<xs:minLength id="5" />' +
                    '</xs:restriction>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     res = Restriction.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))))
     res.id.should == "r1"
     res.base.should == "xs:integer"
     res.attribute_groups.size.should == 2
     res.min_length.should == nil

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:simpleContent id="sc1">' +
                    '<xs:restriction id="r1">'+
                        '<xs:attributeGroup id="ag1" />' +
                        '<xs:attributeGroup id="ag2" />' +
                        '<xs:minLength value="5" />' +
                        '<xs:maxExclusive value="15" />' +
                        '<xs:pattern value="[a-zA-Z][a-zA-Z][a-zA-Z]"/>' +
                        '<xs:enumeration value="foo"/>' +
                        '<xs:enumeration value="bar"/>' +
                    '</xs:restriction>' +
                 '</xs:simpleContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     res = Restriction.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))))
     res.attribute_groups.size.should == 2
     res.min_length.should == 5
     res.max_exclusive.should == 15
     res.pattern.should == "[a-zA-Z][a-zA-Z][a-zA-Z]"
     res.enumerations.size.should == 2
     res.enumerations[0].should == "foo"
  end


  ##########################################################

  it "should parse xml" do
     data = "<root_tag some_string='foo' MyInt='bar' >" +
             "<child_tag>" +
              "<grandchild_tag id='25' />" +
             "</child_tag>" +
            "</root_tag>"

     schema_instance = Parser.parse_xml :raw => data
     schema_instance.object_builders.size.should == 3
     rt = schema_instance.object_builders.find { |ob| ob.tag_name == "root_tag" }
     ct = schema_instance.object_builders.find { |ob| ob.tag_name == "child_tag" }
     gt = schema_instance.object_builders.find { |ob| ob.tag_name == "grandchild_tag" }

     rt.should_not be_nil
     ct.should_not be_nil
     gt.should_not be_nil

     #rt.children.size.should == 1
     #rt.children[0].should == ct

     #ct.children.size.should == 1
     #ct.children[0].should == gt

     rt.attributes.size.should == 2
     rt.attributes.has_key?("some_string").should be == true
     rt.attributes["some_string"].should == "foo"
     rt.attributes.has_key?("MyInt").should == true
     rt.attributes["MyInt"].should == "bar"

     #gt.children.size.should == 0
     gt.attributes.has_key?("id").should == true
     gt.attributes["id"].should == "25"
  end

end
