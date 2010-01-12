# The XSD ComplexContent definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD ComplexContent defintion
# http://www.w3schools.com/Schema/el_complexcontent.asp
class ComplexContent

  # complex content attributes
  attr_accessor :id, :mixed

  # complex content children
  attr_accessor :restriction, :extension

  # complex content parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "complexContent"
  end

  # return xsd node info
  def info
    "complexContent id: #{@id}"
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
     complex_content = ComplexContent.new
     complex_content.parent = node.parent.related
     node.related = complex_content

     # TODO group attributes: | anyAttributes
     complex_content.id       = node.attrs["id"]
     complex_content.mixed    = node.attrs.has_key?("mixed") ? node.attrs["mixed"].to_b : false

     complex_content.restriction   = node.child_obj Restriction
     complex_content.extension     = node.child_obj Extension

     return complex_content
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
  end

  # convert complex content to class builder
  def to_class_builder(cb = nil)
    unless defined? @class_builder
      # dispatch to child restriction/extension
      @class_builder = cb

      if !@restriction.nil?
         @class_builder = @restriction.to_class_builder(@class_builder)
      elsif !@extension.nil?
         @class_builder = @extension.to_class_builder(@class_builder)
      end
    end

    return @class_builder
  end

  # return all child attributes associated w/ complex content
  def child_attributes
     atts = []
     atts += @restriction.child_attributes unless @restriction.nil?
     atts += @extension.child_attributes unless @extension.nil?
     return atts
  end

end

end # module XSD
end # module RXSD
