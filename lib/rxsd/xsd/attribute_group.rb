# The XSD AttributeGroup definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD AttributeGroup defintion
# http://www.w3schools.com/Schema/el_attributegroup.asp
class AttributeGroup

  # attribute group attributes
  attr_accessor :id, :name, :ref

  # attribute group children
  attr_accessor :attributes, :attribute_groups

  # attribute group parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "attributeGroup"
  end

  # return xsd node info
  def info
    "attributeGroup id: #{@id} name: #{@name} ref: #{ref.nil? ? "" : ref.class == String ? ref : ref.name} "
  end

  # returns array of all children
  def children
     @attributes + @attribute_groups
  end

  # node passed in should be a xml node representing the attribute group
  def self.from_xml(node)
     attribute_group = AttributeGroup.new
     attribute_group.parent = node.parent.related
     node.related = attribute_group

     # TODO attribute group attributes: | anyAttributes
     attribute_group.id       = node.attrs["id"]
     attribute_group.name     = node.attrs["name"]
     attribute_group.ref      = node.attrs["ref"]

     # TODO attribute group children: | anyAttribute
     attribute_group.attributes        = node.children_objs Attribute
     attribute_group.attribute_groups = node.children_objs AttributeGroup

     return attribute_group
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
    unless @ref.nil?
      @ref = node_objs.find { |no| no.class == AttributeGroup && no.name == @ref }
    end
  end

  # convert attribute group to array of class builders
  def to_class_builders
    unless defined? @class_builders
      @class_builders = []
      @attributes.each { |att|
         @class_builders.push att.to_class_builder
      }
      @attribute_groups.each { |atg|
         atg.to_class_builders.each { |atcb|
            @class_builders.push atcb
         }
      }
    end

    return @class_builders
  end

end

end # module XSD
end # module RXSD
