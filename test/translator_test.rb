# tests the translator module
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

class TranslatorTest < Test::Unit::TestCase
  def setup
    @data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType name="MyStrType">'+
               '  <xs:restriction base="xs:string" />' +
               '</xs:simpleType>' + 
               '<xs:simpleType name="MyFArrType">'+
               '  <xs:list itemType="xs:float" />' +
               '</xs:simpleType>' + 
               '<xs:complexType id="ct1" name="MyType">' +
                 '<xs:complexContent id="cc1">' +
                    '<xs:extension id="e1" base="xs:string">' +
                        '<xs:attribute name="my_s" type="xs:string"/>' +
                        '<xs:attribute name="my_a" type="MyFArrType" />' +
                    '</xs:extension>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
               '<xs:element name="Foobar" type="MyStrType"/>' +
               '<xs:element name="Foomanchu" type="xs:boolean"/>' +
               '<xs:element name="MoMoney" type="MyType"/>' +
            '</schema>'
  end

  def teardown
  end

  def test_to_classes
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_classes
     assert_equal 6, classes.size
     assert classes.include?(Float)
     assert classes.include?(Array)
     assert classes.include?(String)
     assert classes.include?(Boolean)
     assert classes.include?(Foobar)
     assert classes.include?(MoMoney)
     momoney = MoMoney.new
     assert !momoney.method(:my_s).nil?
     assert !momoney.method(:my_s=).nil?
     assert !momoney.method(:my_a).nil?
     assert !momoney.method(:my_a=).nil?
  end

  def test_to_class_definitions
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_definitions
     assert_equal 6, classes.size
     assert classes.include?("class Float\nend")
     assert classes.include?("class Array\nend")
     assert classes.include?("class String\nend")
     assert classes.include?("class Boolean\nend")
     assert classes.include?("class Foobar < String\nend")
     assert classes.include?("class MoMoney < String\n" +
                               "attr_accessor :my_s\n" +
                               "attr_accessor :my_a\n" +
                             "end")
  end
end
