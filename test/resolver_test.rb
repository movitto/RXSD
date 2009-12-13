# tests the resolver module
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

class ResolverTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  # FIXME test resolve method on all XSD classes!

  def test_node_objects
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
               '<xs:complexType id="ct1">' +
                 '<xs:choice id="c1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element id="e2" />' +
                 '  <xs:element ref="Foobar" />' +
                 '  <xs:choice id="c2" />' +
                 '  <xs:choice id="c3" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo" />' +
               '</xs:simpleType>' +
               '<xs:element name="Foobar" minOccurs="unbounded"/>' +
               '<xs:element name="Foomanchu"/>' +
            '</schema>'

     schema = Parser.parse_xsd :raw => data
     node_objs = Resolver.node_objects schema

     assert_equal 18, node_objs.size
     assert_equal 2, node_objs.find_all { |no| no.class == ComplexType }.size
     assert_equal 5, node_objs.find_all { |no| no.class == Element }.size
  end

  def test_resolve_nodes
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:element name="Foo"/>' +
               '<xs:complexType name="ct1">' +
                 '<xs:choice id="c1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element ref="Foo" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
               '<xs:element type="ct1" name="Bar"/>' +
            '</schema>'

     schema = Parser.parse_xsd :raw => data
     #node_objs = Resolver.resolve_nodes schema # XXX don't like doing it this way but this is invoked as part of Parser.parse_xsd, and shouldn't be invoked twice on one data set

     assert_equal schema.elements[1].type, schema.complex_types[0]
     assert_equal schema.complex_types[0].choice.elements[1].ref, schema.elements[0]
  end

end
