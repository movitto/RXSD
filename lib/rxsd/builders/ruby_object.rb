# RXSD Ruby Object builder
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Implements the RXSD::ObjectBuilder interface to build Ruby Objects from a xsd-conforming xml doc
class RubyObjectBuilder < ObjectBuilder

   # implementation of RXSD::ObjectBuilder::build
   def build(schema)
      # return object if already built
      return @obj unless @obj.nil?
      
      Logger.debug "instantiating class #{@tag_name} from xsd"

      # find class builder corresponding to tag_name to instantiate
      tags   = schema.tags
      klass  = tags[@tag_name].klass

      # instantiate the target class
      if @content.nil? # not a text based obj, construct normally
        @obj = klass.new
      elsif klass == Array # special case when instantiating arrays, need to specify item type
        @obj = klass.from_s @content, tags[@tag_name].associated_builder.klass
      else
        @obj = klass.from_s @content
      end

      # go through each attribute, find corresponding class builder, 
      # instantiate, and assign to object
      @attributes.each { |atn, atv|
        if tags.has_key? @tag_name + ":" + atn # FIXME how do we want to handle attributes that are not in the schema (eg the else here)
          aklass  = tags[@tag_name + ":" + atn].klass
          if aklass == Array # special case when instantiating arrays, need to specify item type
            val = aklass.from_s atv, tags[@tag_name + ":" + atn].associated_builder.klass
          else
            val = aklass.from_s atv
          end
          @obj.send("#{atn.underscore}=".intern, val)
        end
      }

      # instantiate each child using builder and assign to object
      @children.each { |child|
        cob  = RubyObjectBuilder.new(:builder => child)
        cobj = cob.build(schema)
        @obj.send("#{cob.tag_name.underscore}=".intern, cobj)
      }

      Logger.debug "object type #{@tag_name} instantiated, returning"

      return @obj
   end

end

end
