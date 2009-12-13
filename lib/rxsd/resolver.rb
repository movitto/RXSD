# RXSD resolver
#
# resolves hanging node relationships and provides overall node access
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# resolves 
class Resolver

   # return array of node objs for all nodes
   # underneath given node_obj (inclusive)
   def self.node_objects(node_obj, args = {})
      if args.has_key? :node_objs
        node_objs = args[:node_objs]
      elsif node_obj.nil?
        node_objs = []
      else
        node_objs = [node_obj]
      end

      unless node_obj.nil?
        node_obj.children.each{ |noc|
           unless noc.nil? || node_objs.include?(noc)
             node_objs.push noc 
             node_objs = node_objects(noc, :node_objs => node_objs) # might be better to do a breadth first traversal instead?
           end
        }
      end

      node_objs
   end

   # resolves hanging node relationships for specified schema
   def self.resolve_nodes(schema)
      node_objs = node_objects(schema)
      node_objs.each { |no|
         no.resolve(node_objs)
      }
   end

end # class Resolver
end # module RXSD
