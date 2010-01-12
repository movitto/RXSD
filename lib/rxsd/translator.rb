# RXSD translator
#
# transaltes xsd <-> ruby classes & xml <-> instances
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

# include whatever output builders you want here,
require 'builders/ruby_class'
require 'builders/ruby_definition'
require 'builders/ruby_object'

module RXSD

# Extend XSD Schema Interface to
# translate xsd/xml to / from ruby classes/objects
module XSD
class Schema

   # helper method, return hash of all tag names -> class builders under schema.
   # An tag is an element or attribute name that can appear in a xml document
   # conforming to the schema
   def tags
        unless defined? @tags
          @tags = {}
          Resolver.
            node_objects(self)[Element].
            find_all { |no| no.class == Element }.
            each     { |elem|
              unless elem.name.nil?
                @tags[elem.name] = elem.to_class_builder
                eca = elem.child_attributes
                eca.each { |att|
                  @tags[elem.name + ":" + att.name] = att.to_class_builder # prepend element to attribute name to prevent conflicts
                } unless eca.nil?
              end
            }
        end
        return @tags
   end

   # helper method, return all class builders in/under schema
   def all_class_builders
        to_class_builders.collect { |cb| cb.associated.push cb }.flatten.uniq.compact # FIXME this only filters duplicates by obj id,
                                                                                      # its possible we have multiple objects refering
                                                                                      # to the same type, should filter these out here or sometime b4
   end

   # translates schema and all child entities to instances of specified output type.
   # output_type may be one of
   #   * :ruby_classes
   #   * :ruby_definitions
   def to(output_type)
      cbs = all_class_builders
      results = []
      cbs.each { |cb|
        # probably a better way to do this at some point than invoking the copy constructors
        #
        # FIXME we create class builders in the translator on the fly, this may cause
        # problems for later operations that need to access class builder attributes which
        # have been created
        case(output_type)
         when :ruby_classes
            cl = RubyClassBuilder.new(:builder => cb).build
            results.push cl unless results.include? cl
            cb.klass = cl # small hack to get around the above fixme... for now
         when :ruby_definitions
            df = RubyDefinitionBuilder.new(:builder => cb).build
            results.push df unless results.include? df
        end
      }
      return results
   end

end # class Schema

end # module XSD

# SchemaInstance contains an array of ObjectBuilders and provides
# mechanism to instantiate objects from conforming to a xsd schema
class SchemaInstance

  # array of object builders represented by current instance
  attr_accessor :object_builders

  # return array of ObjectBuilders parsed out of a RXSD::XML::Node.
  # Optionally specify parent ObjectBuilder to use
  def self.builders_from_xml(node, parent = nil)
     node_builder = ObjectBuilder.new(:tag_name => node.name, :attributes => node.attrs, :parent => parent)
     parent.children.push node_builder unless parent.nil? || parent.children.include?(node_builder)
     builders = [ node_builder ]
     node.children.each { |c|
        if c.text?
          node_builder.content = c.content  if node.children.size == 1 # FIXME if text/children-elements be mixed under a node this wont work
        else
          builders += SchemaInstance.builders_from_xml(c, node_builder )
        end
     }
     return builders
  end

  # create new schema instance w/ specified args
  def initialize(args = {})
    @object_builders = args[:builders] if args.has_key? :builders
  end

  # translates SchemaInstance's objects into instances of the specified output type.
  # :output_type may be one of
  #   * :ruby_objects
  # Must specify :schema argument containing RXSD::XSD::Schema to use in object creation
  def to(output_type, args = {})
    schema = args[:schema]
    results = []
    @object_builders.each { |ob|
       # probably a better way to do this at some point than invoking the copy constructors
       case(output_type)
          when :ruby_objects
            ob = RubyObjectBuilder.new(:builder => ob).build(schema)
            results.push ob
       end
    }
    return results
  end

end

end # module RXSD
