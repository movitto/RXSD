# The XSD Element definition
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD
module XSD

# XSD Element defintion
# http://www.w3schools.com/Schema/el_element.asp
class Element

  # element attribute values
  attr_accessor :id, :name, :type, 
                :nillable, :abstract, :ref, 
                :substitionGroup, :form, :maxOccurs,
                 :minOccurs, :default, :fixed

  # simple type in element
  attr_accessor :simple_type

  # complex type in element
  attr_accessor :complex_type

  # element parent
  attr_accessor :parent

  # xml tag name
  def self.tag_name
    "element"
  end

  # return xsd node info
  def info
    "element id: #{@id} name: #{@name} type: #{@type.class} ref: #{ref.nil? ? "" : ref.class == String ? ref : ref.name} "
  end

  # returns array of all children
  def children
    c = []
    c.push @simple_type unless @simple_type.nil?
    c.push @complex_type unless @complex_type.nil?
    return c
  end

  # node passed in should be a xml node representing the element
  def self.from_xml(node)
     element = Element.new
     element.parent = node.parent.related
     node.related = element

     # TODO element attrs: | block / final
     # TODO element children:   | key, keyref, unique

     element.id       = node.attrs["id"]
     element.name     = node.attrs["name"]
     element.type     = node.attrs["type"]
     element.nillable  = node.attrs.has_key?("nillable") ? node.attrs["nillable"].to_b : false
     element.abstract  = node.attrs.has_key?("abstract") ? node.attrs["abstract"].to_b : false

     unless node.parent.name == Schema.tag_name
       # FIXME ignoring reference namepsace prefix (if any) for now
       ref = node.attrs["ref"]
       ref = ref.split(':')[1] if !(ref.nil? || ref.index(":").nil?)
       element.ref              = ref

       element.substitionGroup  = node.attrs["substitionGroup"]
       element.form             = node.attrs.has_key?("form") ? 
                                     node.attrs["form"] :
                                      node.root.attrs["elementFormDefault"]

       element.maxOccurs  = node.attrs.has_key?("maxOccurs") ? 
                                (node.attrs["maxOccurs"] == "unbounded" ? "unbounded" : node.attrs["maxOccurs"].to_i) : 1
       element.minOccurs  = node.attrs.has_key?("minOccurs") ? 
                                (node.attrs["minOccurs"] == "unbounded" ? "unbounded" : node.attrs["minOccurs"].to_i) : 1

     else
       element.form = node.parent.attrs["elementFormDefault"]
     end

     if node.text? || !node.children.find { |c| c.name == SimpleType.tag_name }.nil?
       element.default  = node.attrs["default"]
       element.fixed    = node.attrs["fixed"]
     end

     element.simple_type = node.child_obj SimpleType
     element.complex_type = node.child_obj ComplexType

     return element
  end

  # resolve hanging references given complete xsd node object array
  def resolve(node_objs)
    unless @type.nil?
      builtin  = Parser.parse_builtin_type @type
      simple   = node_objs[SimpleType].find  { |no| no.name == @type }
      complex  = node_objs[ComplexType].find { |no| no.name == @type }
      if !builtin.nil?
        @type = builtin
      elsif !simple.nil?
        @type = simple
      elsif !complex.nil?
        @type = complex
      end
    end

    unless @ref.nil?
      @ref = node_objs[Element].find { |no| no.name == @ref }
    end
    
    unless @substitionGroup.nil?
      @substitutionGroup = node_objs[Element].find { |no| no.name == @substitionGroup }
    end
  end

  # convert element to class builder
  def to_class_builder
     unless defined? @class_builder
       @class_builder = nil

       if !@ref.nil? 
          @class_builder = @ref.to_class_builder

       elsif !@type.nil?
          if @type.class == SimpleType || @type.class == ComplexType
            @class_builder = @type.to_class_builder.clone # need to clone here as we're refering to a type that may be used elsewhere
          else
            @class_builder = ClassBuilder.new :klass => @type
          end

       elsif !@simple_type.nil?
          @class_builder = @simple_type.to_class_builder

       elsif !@complex_type.nil?
          @class_builder = @complex_type.to_class_builder

       end

       @class_builder.klass_name = @name.camelize unless @class_builder.nil? || @name == "" || @name.nil?
     end

     return @class_builder
  end

  # return all child attributes associated w/ element
  def child_attributes
     if !@ref.nil?
        return @ref.child_attributes
     elsif[SimpleType, ComplexType].include? @type.class
        return @type.child_attributes
     elsif !@simple_type.nil?
        return @simple_type.child_attributes
     elsif !@complex_type.nil?
        return @complex_type.child_attributes
     end
  end


end

end # module XSD
end # module RXSD
