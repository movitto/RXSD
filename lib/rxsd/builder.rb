# RXSD builder
#
# responsible for providing simple interface to build ruby classes
# and output them in various formats, eg verbatim, text, etc
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# build ruby class from specified parameters
class ClassBuilder
   # actual ruby class built
   attr_accessor :klass

   # name of ruby class to build
   attr_accessor :klass_name

   # class builder corresponding to associated type where approprate
   attr_accessor :associated_builder

   # class builder corresponding to base type where approprate
   attr_accessor :base_builder
   
   # array of class builders for all attributes
   attr_accessor :attribute_builders

   # name of the attribute which this class represents, for use in accessor construction
   attr_accessor :attribute_name

   # create a new class builder w/ specified args
   def initialize(args = {})
      @klass = args[:klass]
      @klass_name = args[:klass_name]

      if args.has_key? :base_builder
        @base_builder = args[:base_builder]
      elsif args.has_key?(:base) && !args[:base].nil?
        @base_builder = ClassBuilder.new :klass => args[:base]
      end

      @attribute_builders = []
   end

   # build Ruby Class instance using this builder
   def build_class
      # if buildin, just return it
      return @klass if  Parser.is_builtin? @klass

      # need the class name to build class
      return nil    if @klass_name.nil?

      Logger.debug "building class #{@klass}/#{@klass_name} from xsd"

      # determine object's superclass, creating it if need be
      superclass = Object
      unless @base_builder.nil?
        if @base_builder.klass.nil?
          @base_builder.build_class
        end
        superclass = @base_builder.klass
      end

      # create object
      unless Object.constants.include? @klass_name
        Object.const_set(@klass_name, Class.new(superclass))
      end
      @klass = @klass_name.constantize

      # define accessors for attributes
      @attribute_builders.each { |atb|
        unless atb.nil?
          att_name = nil
          if !atb.attribute_name.nil?
             att_name = atb.attribute_name.underscore
          elsif !atb.klass_name.nil?
             att_name = atb.klass_name.underscore
          elsif !atb.klass.nil?
             att_name = atb.klass.to_s.underscore
          end

          @klass.send :attr_accessor,  att_name.intern unless att_name.nil?
        end
      }

      Logger.debug "class #{@klass} built, returning"
      return @klass
   end

   # build Ruby Class definition using this builder
   def build_definition
      return "class #{@klass.to_s}\nend" if Parser.is_builtin? @klass

      # need the class name to build class
      return nil    if @klass_name.nil?

      Logger.debug "building definition for #{@klass}/#{@klass_name}  from xsd"

      # defined class w/ base
      superclass = "Object"
      unless @base_builder.nil?
        if    ! @base_builder.klass_name.nil?
          superclass = @base_builder.klass_name
        elsif ! @base_builder.klass.nil?
          superclass = @base_builder.klass.to_s
        end
      end
      res = "class " + @klass_name + " < " + superclass + "\n"

      # define accessors for attributes
      @attribute_builders.each { |atb|
        unless atb.nil?
          att_name = nil
          if !atb.attribute_name.nil?
             att_name = atb.attribute_name.underscore
          elsif !atb.klass_name.nil?
             att_name = atb.klass_name.underscore
          else
             att_name = atb.klass.to_s.underscore
          end

          res += "attr_accessor :#{att_name}\n"
        end
      }
      res += "end"

      Logger.debug "definition #{res} built, returning"
      return res
   end

   # helper method to get all associated class builders
   def associated
       builders = []

       unless @base_builder.nil? || builders.include?(@base_builder)
         builders.push @base_builder
         builders += @base_builder.associated
       end

       unless @associated_builder.nil? || builders.include?(@associated_builder)
         builders.push @associated_builder
         builders += @associated_builder.associated
       end

       @attribute_builders.each { |ab|
         unless ab.nil? || builders.include?(ab)
           builders.push ab
           builders += ab.associated
         end
       }

       return builders
   end

end # class ClassBuilder
end # module RXSD
