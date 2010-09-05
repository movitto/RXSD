# RXSD resolver
#
# resolves hanging node relationships and provides overall node access
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Resolves xsd relationships, used internally
class Resolver

   # return hash of xsd types -> array of type instances for all nodes
   # underneath given node_obj (inclusive)
   def self.node_objects(node_obj, args = {})
      if args.has_key? :node_objs
        node_objs = args[:node_objs]
      else
        # TODO auto generate keys from classes defined under the XSD module
        node_objs = {XSD::Attribute => [], XSD::AttributeGroup => [], XSD::Choice => [],
                     XSD::ComplexContent => [], XSD::ComplexType => [], XSD::Element => [],
                     XSD::Extension => [], XSD::Group => [], XSD::List => [], XSD::Restriction => [],
                     XSD::Schema => [], XSD::Sequence => [], XSD::SimpleContent => [], XSD::SimpleType => []}

        unless node_obj.nil?
          node_objs[node_obj.class].push node_obj
        end
      end

      unless node_obj.nil?
        node_obj.children.each{ |noc|
           unless noc.nil? || node_objs[noc.class].include?(noc)
             node_objs[noc.class].push noc
             node_objs = node_objects(noc, :node_objs => node_objs) # might be better to do a breadth first traversal instead?
           end
        }
      end

      node_objs
   end

   # resolves hanging node relationships for specified schema
   def self.resolve_nodes(schema)
      node_objs = node_objects(schema)
      node_objs.each { |xsd_class, nobjs|
         nobjs.each{ |no|
           no.resolve(node_objs)
         }
      }
   end

end # class Resolver
end # module RXSD
