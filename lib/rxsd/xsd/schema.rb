# The XSD Schema definition
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# Schema defintion, top level XSD element
# http://www.w3schools.com/Schema/el_schema.asp
class Schema

  # hash of prefix => namespace values
  #  " is the key of the default namespace (or use default_namespace)
  attr_accessor :namespaces
  
  # schema attribute values
  attr_accessor :version, :targetNamespace, :elementFormDefault, :attributeFormDefault

  # arrays of children in schema
  attr_accessor :elements, :simple_types, :complex_types, :attributes, :attribute_groups, :groups

  # parent, always nil but here for conformity
  attr_accessor :parent

  # return default namespace
  def default_namespace
     @namespaces[""]
  end

  # xml tag name
  def self.tag_name
    "schema"
  end

  # return xsd node info
  def info
    "schema"
  end

  # returns array of all schema children
  def children
    ([@elements] + [@simple_types] + [@complex_types] + [@attributes] + 
     [@attribute_groups] + [@groups]).flatten
  end

  # node passed in should be a xml root node representing the schema
  def self.from_xml(node)
     schema = Schema.new
     schema.parent = nil
     node.related= schema

     # set namespaces 
     schema.namespaces = {}
     node.namespaces.each{ |ns| schema.namespaces[ns.prefix] = ns.href }

     # parse version out of attrs
     schema.version = node.attrs["version"]

     # parse target namespace out of attrs
     schema.targetNamespace = node.attrs["targetNamespace"]

     # parse elementFormDefault out of attrs
     schema.elementFormDefault = node.attrs["elementFormDefault"]

     # parse attributeFormDefault out of attrs
     schema.attributeFormDefault = node.attrs["attributeFormDefault"]

     # TODO schema attrs: | blockDefault / finalDefault / anyAttr
     # TODO schema children: | import, notation, redefine / anyChild
     # FIXME handle "xs:include" (use Loader?)

     # parse elements
     schema.elements = node.children_objs Element

     # parse simple types
     schema.simple_types = node.children_objs SimpleType

     # parse complex types
     schema.complex_types = node.children_objs ComplexType

     # parse attributes
     schema.attributes = node.children_objs Attribute

     # parse attribute groups
     schema.attribute_groups = node.children_objs AttributeGroup

     # parse groups
     schema.groups = node.children_objs Group
     
     return schema
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
     # right now does nothing
     #   (possible resolve include/import here)
  end

  # convert schema to array of class builders
  def to_class_builders
     unless defined? @class_builder
       @class_builders = []
       @elements.each { |e|
         @class_builders.push e.to_class_builder
       }
     end

     return @class_builders
  end

end

end # module XSD
end # module RXSD
