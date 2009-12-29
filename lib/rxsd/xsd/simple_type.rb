# The XSD SimpleType definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD SimpleType defintion
# http://www.w3schools.com/Schema/el_simpletype.asp 
class SimpleType

  # simple type attribute values
  attr_accessor :id, :name

  # children in schema (only one will be populated)
  attr_accessor  :list, :restriction

  # simpleType parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "simpleType"
  end

  # return xsd node info
  def info
    "simple_type id: #{@id} name: #{@name}"
  end

  # returns array of all children
  def children
    c = []
    c.push @list unless @list.nil?
    c.push @restriction unless @restriction.nil?
    return c
  end

  # node passed in should be a xml node representing the simple type
  def self.from_xml(node)
     simpleType = SimpleType.new
     simpleType.parent = node.parent.related
     node.related = simpleType

     # TODO simpleType attributes: | anyAttr 
     simpleType.id   = node.attrs["id"]
     simpleType.name = node.attrs["name"]

     # parse lists
     simpleType.list = node.child_obj List

     # parse restrictions
     simpleType.restriction = node.child_obj Restriction

     # TODO simpleType children: | unions
     #simpleType.unions = node.child_obj Union

     return simpleType
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
  end

  # convert simple type to class builder
  def to_class_builder
    unless defined? @class_builder
      @class_builder = nil

      if !@list.nil?
        # dispatch to child list
        @class_builder = @list.to_class_builder

      elsif !@restriction.nil?
        # grab restriction class builder w/ base class and facets
        @class_builder = @restriction.to_class_builder

      #else
      #  @class_builder = ClassBuilder.new

      end
    end

    @class_builder.klass_name = @name.camelize unless @name.nil?
    return @class_builder
  end

  # return all child_attributes associated w/ simple type
  def child_attributes
     if !@list.nil?
        return @list.child_attributes
     elsif !@restriction.nil?
        return @restriction.child_attributes
     end
  end

end

end # module XSD
end # module RXSD
