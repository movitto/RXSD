# RXSD translator
#
# transaltes xsd <-> ruby classes & xml <-> instances
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Extend XSD Schema Interface to
# translate xsd/xml to / from ruby classes/objects
module XSD
class Schema

   # translates schema and all child entities to instances of specified output type.
   # output_type may be one of
   #   * :ruby_classes
   #   * :ruby_definitions
   def to(output_type)
      cbs = to_class_builders.collect { |cb| cb.associated.push cb }.flatten # FIXME filter duplicates
      results = []
      cbs.each { |cb|
        case(output_type)
         when :ruby_classes
            cl = cb.build_class
            results.push cl unless results.include? cl
         when :ruby_definitions
            df = cb.build_definition
            results.push df unless results.include? df
        end
      }
      return results
   end

end # class Schema

end # module XSD
end # module RXSD
