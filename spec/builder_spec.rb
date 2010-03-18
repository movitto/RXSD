# tests the builder module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe "Builder" do

  # test to_class_builder method on all XSD classes

  it "should return schema class builders" do
    schema = Schema.new
    elem1  = MockXSDEntity.new
    elem2  = MockXSDEntity.new

    schema.elements = [elem1, elem2]
    class_builders = schema.to_class_builders

    class_builders.size.should == 2
    class_builders[0].class.should == ClassBuilder
    class_builders[0].instance_variable_get("@xsd_obj").should == elem1
    class_builders[1].class.should == ClassBuilder
    class_builders[1].instance_variable_get("@xsd_obj").should == elem2
  end

  it "should return element class builders" do
    elem1 = MockXSDEntity.new
    st1   = MockXSDEntity.new
    ct1   = MockXSDEntity.new

    element = Element.new
    element.name = "foo_element"
    element.ref = elem1
    cb = element.to_class_builder
    cb.class.should == ClassBuilder
    cb.instance_variable_get("@xsd_obj").should == elem1
    cb.klass_name.should == "FooElement"

    # FIXME the next two 'type' test cases need to be fixed / expanded
    element = Element.new
    element.name = "bar_element"
    element.type = st1
    cb = element.to_class_builder
    cb.class.should == ClassBuilder
    #cb.instance_variable_get("@xsd_obj").should == st1     TODO since clone is invoked, @xsd_obj test field never gets copied, fix this
    cb.klass_name.should == "BarElement"

    element = Element.new
    element.type = ct1
    cb = element.to_class_builder
    cb.class.should == ClassBuilder
    #cb.instance_variable_get("@xsd_obj").should == ct1

    element = Element.new
    element.simple_type = st1
    cb = element.to_class_builder
    cb.class.should == ClassBuilder
    cb.instance_variable_get("@xsd_obj").should == st1

    element = Element.new
    element.complex_type = ct1
    cb = element.to_class_builder
    cb.class.should == ClassBuilder
    cb.instance_variable_get("@xsd_obj").should == ct1
  end

  # FIXME test other XSD classes' to_class_builder methods

  ##########

  it "should correctly return associated builders" do
     gp = ClassBuilder.new
     p  = ClassBuilder.new :base_builder => gp
     c  = ClassBuilder.new :base_builder => p
     as = ClassBuilder.new 
     c.associated_builder = as
     at1 = ClassBuilder.new
     at2 = ClassBuilder.new
     c.attribute_builders.push at1
     c.attribute_builders.push at2

     ab = c.associated
     ab.size.should == 5
  end

  it "should build class" do
     cb1 = RubyClassBuilder.new :klass => String, :klass_name => "Widget"
     cb1.build.should == String

     cb2 = RubyClassBuilder.new :klass_name => "Foobar"
     c2 = cb2.build
     c2.should == Foobar
     c2.superclass.should == Object

     acb = RubyClassBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1
     ac = acb.build
     ac.should == Array

     tcb = RubyClassBuilder.new :klass_name => "CamelCased"

     cb3 = RubyClassBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     c3 = cb3.build
     c3.should == Foomoney
     c3.superclass.should == Foobar
     c3i = c3.new
     c3i.method(:widget).should_not be_nil
     c3i.method(:widget).arity.should == 0
     c3i.method(:widget=).should_not be_nil
     c3i.method(:widget=).arity.should == 1
     c3i.method(:camel_cased).should_not be_nil
     c3i.method(:camel_cased).arity.should == 0
     c3i.method(:camel_cased=).should_not be_nil
     c3i.method(:camel_cased=).arity.should == 1
     c3i.method(:arr_socket).should_not be_nil
     c3i.method(:arr_socket).arity.should == 0
     c3i.method(:arr_socket=).should_not be_nil
     c3i.method(:arr_socket=).arity.should == 1
  end

  it "should build definition" do
     cb1 = RubyDefinitionBuilder.new :klass => String, :klass_name => "Widget"
     cb1.build.should == "class String\nend"

     cb2 = RubyDefinitionBuilder.new :klass_name => "Foobar"
     d2 = cb2.build
     d2.should == "class Foobar < Object\nend"

     acb = RubyDefinitionBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1
     ad = acb.build
     ad.should == "class Array\nend"

     tcb = RubyDefinitionBuilder.new :klass_name => "CamelCased"

     cb3 = RubyDefinitionBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     d3 = cb3.build
     d3.should == "class Foomoney < Foobar\n" +
                  "attr_accessor :widget\n" +
                  "attr_accessor :camel_cased\n" +
                  "attr_accessor :arr_socket\n" +
                  "end"
  end

  it "should build object" do
     schema_data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'>" +
                   "<xs:element name='Godzilla'>" +
                     "<xs:complexType>" +
                       "<xs:simpleContent>" +
                         "<xs:extension base='xs:string'>" +
                           "<xs:attribute name='first_attr' type='xs:string' />" +
                           "<xs:attribute name='SecondAttr' type='xs:integer' />" +
                         "</xs:extension>" +
                       "</xs:simpleContent>"+
                     "</xs:complexType>"+
                   "</xs:element>" +
                   "</schema>"

     schema = Parser.parse_xsd :raw => schema_data
     rbclasses = schema.to :ruby_classes

     rob = RubyObjectBuilder.new :tag_name => "Godzilla", :content => "some stuff", :attributes => { "first_attr" => "first_val", "SecondAttr" => "420" }
     obj = rob.build schema

     obj.class.should == Godzilla
     obj.should == "some stuff"  # since obj derives from string
     obj.first_attr.should == "first_val"
     obj.second_attr.should == 420


     schema_data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'>" +
                      '<xs:element name="employee" type="fullpersoninfo"/>' +
                         '<xs:complexType name="personinfo">'+
                            '<xs:attribute name="ssn" type="xs:string" />' +
                            '<xs:sequence>'+
                               '<xs:element name="firstname" type="xs:string"/>'+
                               '<xs:element name="lastname" type="xs:string"/>'+
                            '</xs:sequence>'+
                         '</xs:complexType>'+
                         '<xs:complexType name="fullpersoninfo">'+
                           '<xs:complexContent>'+
                             '<xs:extension base="personinfo">'+
                               '<xs:attribute name="residency" type="xs:string" />' +
                               '<xs:sequence>'+
                                 '<xs:element name="address" type="xs:string"/>'+
                                 '<xs:element name="country" type="xs:string"/>'+
                               '</xs:sequence>'+
                             '</xs:extension>'+
                           '</xs:complexContent>'+
                         '</xs:complexType> '+
                   "</schema>"

     schema = Parser.parse_xsd :raw => schema_data
     rbclasses = schema.to :ruby_classes

     rob = RubyObjectBuilder.new :tag_name => "employee", :attributes => { "ssn" => "111-22-3333", "residency" => "citizen" },
                             :children => [ ObjectBuilder.new(:tag_name => "firstname", :content => "mo" ),
                                            ObjectBuilder.new(:tag_name => "lastname",  :content => "morsi"),
                                            ObjectBuilder.new(:tag_name => "address",   :content => "wouldn't you like to know :-p"),
                                            ObjectBuilder.new(:tag_name => "country",   :content => "USA") ]

     obj = rob.build schema

     obj.class.should == Employee
     obj.ssn.should == "111-22-3333"
     obj.residency.should == "citizen"
     obj.firstname.should == "mo"
     obj.lastname.should == "morsi"
     obj.country.should == "USA"
  end
end

class MockXSDEntity
  def to_class_builder
     cb = ClassBuilder.new
     cb.instance_variable_set("@xsd_obj", self)
     return cb
  end
end
