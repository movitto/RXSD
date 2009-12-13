# tests the parser module
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

class ParserTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_parse_xsd
     File.write("/tmp/rxsd-test", "<schema><element name='foo' type='xs:boolean' />" + 
                                  "<complexType><choice><element ref='foo' /></choice></complexType></schema>")
     schema = Parser.parse_xsd :uri => "file:///tmp/rxsd-test"
     assert_equal 1, schema.elements.size
     assert_equal 1, schema.complex_types.size
     assert_equal "foo", schema.elements[0].name
     assert_equal Boolean, schema.elements[0].type
     assert_equal "foo", schema.complex_types[0].choice.elements[0].ref.name
     assert_equal Boolean, schema.complex_types[0].choice.elements[0].ref.type
  end

  def test_parse_xml
  end

  def test_is_builtin_type
     assert Parser.is_builtin?(String)
     assert Parser.is_builtin?(Boolean)
     assert Parser.is_builtin?(Float)
     assert !Parser.is_builtin?(ParserTest)
  end

  def test_parse_builtin_types
     assert_equal String,  Parser.parse_builtin_type("xs:string")
     assert_equal Boolean, Parser.parse_builtin_type("xs:boolean")
     assert_equal Float,   Parser.parse_builtin_type("xs:decimal")
     assert_equal Float,   Parser.parse_builtin_type("xs:float")
     assert_equal Float,   Parser.parse_builtin_type("xs:double")
  end

  def test_parse_schema
     data = "<schema version='4.20' targetNamespace='foobar' xmlns='http://www.w3.org/2001/XMLSchema' xmlns:foo='http://morsi.org/myschema' " +
            "   elementFormDefault='qualified' attributeFormDefault='unqualified' />"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(doc.root)
     assert_equal 2, schema.namespaces.size
     assert_equal 'foobar', schema.targetNamespace
     assert_equal 'http://www.w3.org/2001/XMLSchema', schema.namespaces[nil]
     assert_equal 'http://morsi.org/myschema', schema.namespaces['foo']
     assert_equal "qualified", schema.elementFormDefault
     assert_equal "unqualified", schema.attributeFormDefault

     data = "<schema><element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(doc.root)
     assert_equal 1, schema.elements.size
     assert_equal "foo", schema.elements[0].id

     data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'><xs:element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(doc.root)
     assert_equal 1, schema.elements.size
     assert_equal "foo", schema.elements[0].id
  end

  def test_parse_element
     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:element id="iii" name="xxx" type="yyy" default="Foobar" maxOccurs="5" '+
                 ' nillable="true" abstract="true" ref="Foo" form="qualified" />' +
            '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(doc.root.children[0])
     assert_equal "iii", element.id
     assert_equal "xxx", element.name
     assert_equal "yyy", element.type
     assert_equal nil, element.default
     assert_equal 5, element.maxOccurs
     assert_equal 1, element.minOccurs
     assert_equal true, element.nillable
     assert_equal true, element.abstract
     assert_equal "Foo", element.ref
     assert_equal "qualified", element.form

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
                '<xs:element default="Foobar" minOccurs="unbounded">' +
                   '<Foo/>' +
                '</xs:element>' +
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(doc.root.children[0])
     assert_equal nil, element.default
     assert_equal "unbounded", element.minOccurs

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="unqualified">'+
                '<xs:element id="iii" ref="Foo" />'+
             '</schema>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(doc.root.children[0])
     assert_equal "iii", element.id
     assert_equal nil, element.ref
     assert_equal "unqualified", element.form

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
              '<xs:element default="Foobar" minOccurs="unbounded">' +
                '<simpleType id="foobar"/>' +
              '</xs:element>'+
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(doc.root.children[0])
     assert_equal "Foobar", element.default
     assert_equal "foobar", element.simple_type.id
  end

  def test_parse_complex_type
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="iii" name="xxx" abstract="true" mixed="true">' +
                 '<xs:attribute name="Foo" />' +
                 '<xs:attribute name="Bar" />' +
                 '<xs:group name="Gr" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(doc.root.children[0])
     assert_equal "iii", complexType.id
     assert_equal "xxx", complexType.name
     assert_equal true, complexType.abstract
     assert_equal true, complexType.mixed
     assert_equal 2, complexType.attributes.size
     assert_equal "Foo", complexType.attributes[0].name
     assert_equal "Bar", complexType.attributes[1].name
     assert_equal "Gr", complexType.group.name

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType mixed="true">' +
                 '<xs:simpleContent id="123" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(doc.root.children[0])
     assert_equal false, complexType.mixed
     assert_equal "123", complexType.simple_content.id
  end

  def test_parse_simple_type
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="iii" name="xxx">' +
                 '<xs:restriction id="rs1" />' +
                 '<xs:list id="li1" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     simpleType = SimpleType.from_xml(doc.root.children[0])
     assert_equal "iii", simpleType.id
     assert_equal "xxx", simpleType.name
     assert_equal "rs1", simpleType.restriction.id
     assert_equal "li1", simpleType.list.id
  end

  def test_parse_attribute
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attribute id="at1" name="at1" use="optional" form="qualified" default="123" type="foo" />' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(doc.root.children[0])
     assert_equal "at1", attr.id
     assert_equal "at1", attr.name
     assert_equal "qualified", attr.form
     assert_equal "123", attr.default
     assert_equal "foo", attr.type
     assert_equal nil, attr.simple_type

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" attributeFormDefault="unqualified" >' +
               '<xs:attribute id="at2" fixed="123" type="foo">' +
                 '<xs:simpleType id="st1" />' +
               '</xs:attribute>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(doc.root.children[0])
     assert_equal "at2", attr.id
     assert_equal "unqualified", attr.form
     assert_equal nil, attr.type
     assert ! attr.simple_type.nil?
     assert_equal "st1", attr.simple_type.id
  end

  def test_parse_attribute_group
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attributeGroup id="ag1" name="ag1" ref="ag2">' +
                  '<xs:attribute id="a1" />' +
                  '<xs:attribute id="a2" />' +
                  '<xs:attributeGroup id="ag3" />' +
               '</xs:attributeGroup>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attrGroup = AttributeGroup.from_xml(doc.root.children[0])
     assert_equal "ag1", attrGroup.id
     assert_equal "ag1", attrGroup.name
     assert_equal "ag2", attrGroup.ref
     assert_equal 2, attrGroup.attributes.size
     assert_equal 1, attrGroup.attribute_groups.size
     assert_equal "a1", attrGroup.attributes[0].id
     assert_equal "a2", attrGroup.attributes[1].id
     assert_equal "ag3", attrGroup.attribute_groups[0].id
  end

  def test_parse_group
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g1" name="g1" maxOccurs="5" minOccurs="unbounded">' +
                  '<xs:choice id="c1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(doc.root.children[0])
     assert_equal "g1", group.id
     assert_equal "g1", group.name
     assert_equal 5, group.maxOccurs
     assert_equal "unbounded", group.minOccurs
     assert_equal "c1", group.choice.id

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g2" ref="g1" >'+
                  '<xs:sequence id="s1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(doc.root.children[0])
     assert_equal "g1", group.ref
     assert_equal 1, group.minOccurs
     assert_equal 1, group.maxOccurs
     assert_equal "s1", group.sequence.id
  end

  def test_parse_list
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo">' +
                   '<xs:simpleType id="st2" />' +
                 '</xs:list>' + 
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(doc.root.children[0].children[0])
     assert_equal "li1", list.id
     assert_equal nil, list.itemType
     assert_equal "st2", list.simple_type.id

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(doc.root.children[0].children[0])
     assert_equal "Foo", list.itemType
  end

  def test_parse_simple_content
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:simpleContent id="sc1">' +
                 '  <xs:restriction id="r1" />' +
                 '</xs:simpleContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     simple_content = SimpleContent.from_xml(doc.root.children[0].children[0])
     assert_equal "sc1", simple_content.id
     assert_equal "r1", simple_content.restriction.id
  end

  def test_parse_choice
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
     choice = Choice.from_xml(doc.root.children[0].children[0])
     assert_equal "c1", choice.id
     assert_equal 5, choice.maxOccurs
     assert_equal "unbounded", choice.minOccurs
     assert_equal 3, choice.elements.size
     assert_equal "e2", choice.elements[1].id
     assert_equal 2, choice.choices.size
     assert_equal "c2", choice.choices[0].id

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:choice id="c1" >'+
                 '  <xs:sequence id="s1" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     choice = Choice.from_xml(doc.root.children[0].children[0])
     assert_equal 1, choice.maxOccurs
     assert_equal 1, choice.minOccurs
     assert_equal 1, choice.sequences.size
     assert_equal "s1", choice.sequences[0].id
  end

  def test_parse_complex_content
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:restriction id="r1"/>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexContent = ComplexContent.from_xml(doc.root.children[0].children[0])
     assert_equal "cc1", complexContent.id
     assert_equal true, complexContent.mixed
     assert_equal "r1", complexContent.restriction.id
  end

  def test_parse_sequence
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
     seq = Sequence.from_xml(doc.root.children[0].children[0])
     assert_equal "s1", seq.id
     assert_equal 5, seq.maxOccurs
     assert_equal "unbounded", seq.minOccurs
     assert_equal 3, seq.elements.size
     assert_equal "e2", seq.elements[1].id
     assert_equal 2, seq.choices.size
     assert_equal "c2", seq.choices[0].id
  end

  def test_parse_extension
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
     ext = Extension.from_xml(doc.root.children[0].children[0].children[0])
     assert_equal "e1", ext.id
     assert_equal "Foo", ext.base
     assert_equal "g1", ext.group.id
     assert_equal 2, ext.attributes.size
     assert_equal "a1", ext.attributes[0].id
  end

  def test_parse_restriction
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
     res = Restriction.from_xml(doc.root.children[0].children[0].children[0])
     assert_equal "r1", res.id
     assert_equal "xs:integer", res.base
     assert_equal 2, res.attribute_groups.size
     assert_equal nil, res.min_length

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
     res = Restriction.from_xml(doc.root.children[0].children[0].children[0])
     assert_equal 2, res.attribute_groups.size
     assert_equal 5, res.min_length
     assert_equal 15, res.max_exclusive
     assert_equal "[a-zA-Z][a-zA-Z][a-zA-Z]", res.pattern
     assert_equal 2, res.enumerations.size
     assert_equal "foo", res.enumerations[0]
  end
end
