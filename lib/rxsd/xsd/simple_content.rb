# The XSD SimpleContent definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD SimpleContent defintion
# http://www.w3schools.com/Schema/el_simpleContent.asp
class SimpleContent

  # simple content attributes
  attr_accessor :id

  # simple content children
  attr_accessor :restriction, :extension

  # simple content parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "simpleContent"
  end

  # return xsd node info
  def info
    "simple_content id: #{@id}"
  end

  # returns array of all children
  def children
    c = []
    c.push @restriction unless @restriction.nil?
    c.push @extension unless @extension.nil?
    return c
  end

  # node passed in should be a xml node representing the group
  def self.from_xml(node)
     simple_content = SimpleContent.new
     simple_content.parent = node.parent.related
     node.related = simple_content

     # TODO group attributes: | anyAttributes
     simple_content.id       = node.attrs["id"]

     simple_content.restriction   = node.child_obj Restriction
     simple_content.extension     = node.child_obj Extension

     return simple_content
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
  end

  # convert simple content to class builder
  def to_class_builder
    unless defined? @class_builder
      # dispatch to child restriction/extension
      @class_builder = nil

      if !@restriction.nil?
         @class_builder= @restriction.to_class_builder
      elsif !@extension.nil?
         @class_builder= @extension.to_class_builder
      end
    end

    return @class_builder
  end

  # return all child attributes associated w/ simple content
  def child_attributes
     atts = []
     atts += @restriction.child_attributes unless @restriction.nil?
     atts += @extension.child_attributes unless @extension.nil?
     return atts
  end

end

end # module XSD
end # module RXSD
