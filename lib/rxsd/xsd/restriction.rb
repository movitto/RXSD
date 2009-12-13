# The XSD Restriction definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD Restriction defintion
# http://www.w3schools.com/Schema/el_restriction.asp
class Restriction

  # restriction attributes
  attr_accessor :id, :base

  # restriction group children
  attr_accessor :group, :choice, :sequence, :attributes, :attribute_groups, :simple_type

  # restrictions
  attr_accessor :min_exclusive, :min_inclusive, :max_exclusive, :max_inclusive, 
                :total_digits, :fraction_digits, :length, :min_length, :max_length,
                :enumerations, :whitespace, :pattern

  # restriction parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "restriction"
  end

  # return xsd node info
  def info
    "extension id: #{@id} base: #{@base.nil? ? "" : Parser.is_builtin?(@base) ? @base : @base.name }"
  end

  # returns array of all children
  def children
    c = []
    c.push @group  unless @group.nil?
    c.push @choice unless @choice.nil?
    c.push @sequence unless @sequence.nil?
    c += @attributes unless @attributes.nil?
    c += @attribute_groups unless @attribute_groups.nil?
    c.push @simple_type unless @simple_type.nil?
    return c
  end

  # node passed in should be a xml node representing the restriction
  def self.from_xml(node)
     restriction = Restriction.new
     restriction.parent = node.parent.related
     node.related = restriction

     # TODO restriction attributes: | anyAttributes
     restriction.id       = node.attrs["id"]
     restriction.base     = node.attrs["base"]

     if node.parent.name == ComplexContent.tag_name
       # TODO restriction children: | anyAttribute
       restriction.group       = node.child_obj Group
       restriction.choice      = node.child_obj Choice
       restriction.sequence    = node.child_obj Sequence
       restriction.attributes  = node.children_objs Attribute
       restriction.attribute_groups  = node.children_objs AttributeGroup

     elsif node.parent.name == SimpleContent.tag_name
       # TODO restriction children: | anyAttribute
       restriction.attributes       = node.children_objs Attribute
       restriction.attribute_groups = node.children_objs AttributeGroup
       restriction.simple_type   = node.child_obj SimpleType
       parse_restrictions(restriction, node)

     else # SimpleType
       restriction.attributes              = []
       restriction.attribute_groups        = []
       restriction.simple_type = node.child_obj SimpleType
       parse_restrictions(restriction, node)

     end

     return restriction
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
    unless @base.nil?
      builtin = Parser.parse_builtin_type @base
      @base = !builtin.nil? ? builtin : node_objs.find { |no| (no.class == SimpleType || no.class == ComplexType) &&
                                                               no.name == @base }
    end
  end

  # convert restriction to class builder
  def to_class_builder
     unless defined? @class_builder
       # convert restriction to builder 
       if Parser.is_builtin? @base
         @class_builder= ClassBuilder.new :base => @base
       elsif !@base.nil?
         @class_builder= ClassBuilder.new :base_builder => @base.to_class_builder
       else
         @class_builder= ClassBuilder.new
       end

       unless @group.nil?
         @group.to_class_builders.each { |gcb|
           @class_builder.attribute_builders.push gcb
         }
       end

       unless @choice.nil?
         @choice.to_class_builders.each { |ccb|
           @class_builder.attribute_builders.push ccb
         }
       end

       unless @sequence.nil?
         @sequence.to_class_builders.each { |scb|
           @class_builder.attribute_builders.push scb
         }
       end

       @attributes.each { |att|
          @class_builder.attribute_builders.push att.to_class_builder
       }

       @attribute_groups.each { |atg|
          atg.to_class_builders.each { |atcb|
             @class_builder.attribute_builders.push atcb
          }
       }

       unless @simple_type.nil?
         @class_builder.attribute_builders.push @simple_type.to_class_builder
       end

       # FIXME add facets
     end

     return @class_builder
  end


  private

    # internal helper method
    def self.parse_restrictions(restriction, node)
       restriction.min_exclusive = node.child_value("minExclusive").to_i
       restriction.min_inclusive = node.child_value("minInclusive").to_i
       restriction.max_exclusive = node.child_value("maxExclusive").to_i
       restriction.max_inclusive = node.child_value("maxInclusive").to_i
       restriction.total_digits  = node.child_value("totalDigits").to_i
       restriction.fraction_digits  = node.child_value("fractionDigits").to_i
       restriction.length        = node.child_value("length").to_i
       restriction.min_length    = node.child_value("minLength").to_i
       restriction.max_length    = node.child_value("maxLength").to_i
       restriction.enumerations  = node.child_values "enumeration"
       restriction.whitespace    = node.child_value "whitespace"
       restriction.pattern       = node.child_value "pattern"
    end

end

end # module XSD
end # module RXSD
