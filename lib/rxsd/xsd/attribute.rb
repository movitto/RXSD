# The XSD Attribute definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD Attribute defintion
# http://www.w3schools.com/Schema/el_attribute.asp 
class Attribute

  # attribute attributes
  attr_accessor :id, :name, :use, :form, :default, :fixed, :ref, :type

  # attribute children
  attr_accessor :simple_type

  # attribute parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "attribute"
  end

  # return xsd node info
  def info
    "attribute id: #{@id} name: #{@name} type: #{@type.class} ref: #{ref.nil? ? "" : ref.name} "
  end

  # returns array of all children
  def children
    c = []
    c.push @simple_type unless @simple_type.nil?
    return c
  end

  # node passed in should be a xml node representing the attribute
  def self.from_xml(node)
     attribute = Attribute.new
     attribute.parent = node.parent.related
     node.related = attribute

     # TODO attribute attributes: | anyAttributes
     attribute.id       = node.attrs["id"]
     attribute.name     = node.attrs["name"]
     attribute.use      = node.attrs["use"]
 
     attribute.form     = node.attrs.has_key?("form") ? 
                          node.attrs["form"] : node.parent.attrs["attributeFormDefault"]

     attribute.default  = node.attrs["default"]
     attribute.fixed    = node.attrs["fixed"]

     # FIXME ignoring reference namepsace prefix (if any) for now
     ref = node.attrs["ref"]
     ref = ref.split(':')[1] if !(ref.nil? || ref.index(":").nil?)
     attribute.ref              = ref
     
     if node.children.find { |c| c.name == SimpleType.tag_name }.nil?
       attribute.type     = node.attrs["type"]
     else
       attribute.simple_type = node.child_obj SimpleType
     end

     return attribute
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
    unless @type.nil?
      builtin = Parser.parse_builtin_type @type
      @type = !builtin.nil? ? builtin : node_objs.find { |no| no.class == SimpleType && no.name == @type }
    end

    unless @ref.nil?
      @ref = node_objs.find { |no| no.class == Attribute && no.name == @ref }
    end
  end

  # convert complex type to class builder
  def to_class_builder
     unless defined? @class_builder
       @class_builder = nil
       if !@ref.nil? 
          @class_builder = @ref.to_class_builder

       elsif !@type.nil?
          if @type.class == SimpleType
            @class_builder = @type.to_class_builder.clone # need to clone here as we're refering to a type that may be used elsewhere
          else
            @class_builder = ClassBuilder.new :klass => @type
          end

       elsif !@simple_type.nil?
          @class_builder = @simple_type.to_class_builder

       end

       unless @class_builder.nil? || @name == "" || @name.nil?
          @class_builder.attribute_name = @name
          @class_builder.klass_name = @name.camelize if @class_builder.klass.nil? && @class_builder.klass_name.nil?
       end
     end

     return @class_builder
  end

  # return this attribute (or ref if appropriate) in array
  def child_attributes
     return [@ref] unless @ref.nil?
     return [self]
  end

end

end # module XSD
end # module RXSD
