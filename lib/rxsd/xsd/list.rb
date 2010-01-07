# The XSD List definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD List defintion
# http://www.w3schools.com/Schema/el_list.asp
class List

  # list attributes
  attr_accessor :id, :itemType

  # list children
  attr_accessor :simple_type

  # list parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "list"
  end

  # return xsd node info
  def info
    "list id: #{@id}"
  end

  # returns array of all children
  def children
    c = []
    c.push @simple_type unless @simple_type.nil?
    return c
  end

  # node passed in should be a xml node representing the list
  def self.from_xml(node)
     list = List.new
     list.parent = node.parent.related
     node.related = list

     # TODO list attributes: | anyAttributes
     list.id       = node.attrs["id"]


     if node.children.find { |c| c.name == SimpleType.tag_name }.nil?
        list.itemType = node.attrs["itemType"]
     else
        list.simple_type   = node.child_obj SimpleType
     end

     return list
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
    unless @itemType.nil?
      builtin = Parser.parse_builtin_type @itemType
      @itemType = !builtin.nil? ? builtin : node_objs[SimpleType].find { |no| no.name == @itemType }
    end
  end

  # convert list to class builder
  def to_class_builder
     unless defined? @class_builder
       # convert list to builder producing array of classes specified by item type or simple type
       @class_builder = ClassBuilder.new :klass => Array

       if !@itemType.nil?
         if @itemType.class == SimpleType
           @class_builder.associated_builder = @itemType.to_class_builder
         else
           @class_builder.associated_builder = ClassBuilder.new :klass => @itemType
         end

       elsif !@simple_type.nil?
         @class_builder.associated_builder = @simple_type.to_class_builder

       end
     end

     return @class_builder
  end


  # return all child_attributes associated w/ simple type
  def child_attributes
    if !@itemType.nil? && @itemType.class == SimpleType
       return @itemType.child_attributes
    elsif !@simple_type.nil?
       return @simple_type.child_attributes
    end
  end

end

end # module XSD
end # module RXSD
