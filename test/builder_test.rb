# tests the builder module
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

class BuilderTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  # FIXME test to_class_builder  method on all XSD classes!

  def test_associated
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
     assert_equal 5, ab.size
  end

  def test_build_class
     cb1 = ClassBuilder.new :klass => String, :klass_name => "Widget"
     assert_equal String, cb1.build_class

     cb2 = ClassBuilder.new :klass_name => "Foobar"
     c2 = cb2.build_class
     assert_equal Foobar, c2
     assert_equal Object, c2.superclass

     acb = ClassBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1 
     ac = acb.build_class
     assert_equal Array, ac

     tcb = ClassBuilder.new :klass_name => "CamelCased"

     cb3 = ClassBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     c3 = cb3.build_class 
     assert_equal Foomoney, c3
     assert_equal Foobar, c3.superclass
     c3i = c3.new
     assert ! c3i.method(:widget).nil?
     assert_equal 0,  c3i.method(:widget).arity
     assert ! c3i.method(:widget=).nil?
     assert_equal 1,  c3i.method(:widget=).arity
     assert ! c3i.method(:camel_cased).nil?
     assert_equal 0,  c3i.method(:camel_cased).arity
     assert ! c3i.method(:camel_cased=).nil?
     assert_equal 1,  c3i.method(:camel_cased=).arity
     assert ! c3i.method(:arr_socket).nil?
     assert_equal 0,  c3i.method(:arr_socket).arity
     assert ! c3i.method(:arr_socket=).nil?
     assert_equal 1,  c3i.method(:arr_socket=).arity
  end

  def test_build_definition
     cb1 = ClassBuilder.new :klass => String, :klass_name => "Widget"
     assert_equal "class String\nend", cb1.build_definition

     cb2 = ClassBuilder.new :klass_name => "Foobar"
     d2 = cb2.build_definition
     assert_equal "class Foobar < Object\nend", d2

     acb = ClassBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1 
     ad = acb.build_definition
     assert_equal "class Array\nend", ad

     tcb = ClassBuilder.new :klass_name => "CamelCased"

     cb3 = ClassBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     d3 = cb3.build_definition 
     assert_equal "class Foomoney < Foobar\n" +
                  "attr_accessor :widget\n" +
                  "attr_accessor :camel_cased\n" +
                  "attr_accessor :arr_socket\n" +
                  "end", d3
  end
end
