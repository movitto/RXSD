# The XSD Sequence definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD Sequence defintion
# http://www.w3schools.com/Schema/el_sequence.asp
class Sequence

  # sequence attributes
  attr_accessor :id, :maxOccurs, :minOccurs

  # sequence children
  attr_accessor :elements, :groups, :choices, :sequences

  # sequence parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "sequence"
  end

  # return xsd node info
  def info
    "sequence id: #{@id}"
  end

  # returns array of all children
  def children
     @elements + @groups + @choices + @sequences
  end

  # node passed in should be a xml node representing the group
  def self.from_xml(node)
     sequence = Sequence.new
     sequence.parent = node.parent.related
     node.related = sequence

     # TODO sequence attributes: | anyAttributes
     sequence.id       = node.attrs["id"]

     sequence.maxOccurs  = node.attrs.has_key?("maxOccurs") ? 
                              (node.attrs["maxOccurs"] == "unbounded" ? "unbounded" : node.attrs["maxOccurs"].to_i) : 1
     sequence.minOccurs  = node.attrs.has_key?("minOccurs") ? 
                              (node.attrs["minOccurs"] == "unbounded" ? "unbounded" : node.attrs["minOccurs"].to_i) : 1

     # TODO sequence children: | any
     sequence.elements      = node.children_objs Element
     sequence.groups        = node.children_objs Group
     sequence.choices       = node.children_objs Choice
     sequence.sequences     = node.children_objs Sequence

     return sequence
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
  end

  # convert sequence to array of class builders
  def to_class_builders
     # FIXME enforce "all attributes must appear in set order"

     unless defined? @class_builders
       @class_builders = []
       @elements.each { |e|
          @class_builders.push e.to_class_builder
       }
       @groups.each { |g|
          g.to_class_builders { |gcb|
            @class_builders.push gcb
          }
       }
       @choices.each { |c|
          c.to_class_builders { |ccb|
            @class_builders.push ccb
          }
       }
       @sequences.each { |s|
          s.to_class_builders { |scb|
            @class_builders.push scb
          }
       }
     end

     return @class_builders
  end
end

end # module XSD
end # module RXSD
