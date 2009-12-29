# The XSD Group definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD Group defintion
# http://www.w3schools.com/Schema/el_group.asp
class Group

  # group attributes
  attr_accessor :id, :name, :ref, :maxOccurs, :minOccurs

  # group children
  attr_accessor :choice, :sequence

  # group parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "group"
  end

  # return xsd node info
  def info
    "group id: #{@id} name: #{@name} ref: #{ref.nil? ? "" : ref.class == String ? ref : ref.name} "
  end

  # returns array of all children
  def children
    c = []
    c.push @choice unless @choice.nil?
    c.push @sequence unless @sequence.nil?
    return c
  end

  # node passed in should be a xml node representing the group
  def self.from_xml(node)
     group = Group.new
     group.parent = node.parent.related
     node.related = group

     # TODO group attributes: | anyAttributes
     group.id       = node.attrs["id"]
     group.name     = node.attrs["name"]
     group.ref      = node.attrs["ref"]

     group.maxOccurs  = node.attrs.has_key?("maxOccurs") ? 
                              (node.attrs["maxOccurs"] == "unbounded" ? "unbounded" : node.attrs["maxOccurs"].to_i) : 1
     group.minOccurs  = node.attrs.has_key?("minOccurs") ? 
                              (node.attrs["minOccurs"] == "unbounded" ? "unbounded" : node.attrs["minOccurs"].to_i) : 1


     # TODO group children: | element(?)
     group.choice   = node.child_obj Choice
     group.sequence = node.child_obj Sequence

     return group
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
    unless @ref.nil?
      @ref = node_objs.find { |no| no.class == Group && no.name == @ref }
    end
  end

  # convert group to array of class builders
  def to_class_builders
    unless defined? @class_builder
      # just dispatch to ref or child
      @class_builder = []

      if !@ref.nil?
         @class_builder = @ref.to_class_builders
      elsif !@choice.nil?
         @class_builder =  @choice.to_class_builders
      elsif !@sequence.nil?
         @class_builder =  @sequence.to_class_builders
      end
    end

    return @class_builder
  end

    # return all child attributes assocaited w/ group
    def child_attributes
       atts = []
       atts += @sequence.child_attributes  unless @sequence.nil?
       atts += @choice.child_attributes    unless @choice.nil?
       return atts
    end

end

end # module XSD
end # module RXSD
