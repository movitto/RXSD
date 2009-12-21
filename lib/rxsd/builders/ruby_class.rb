# RXSD Ruby Class builder
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Implements the RXSD::ClassBuilder interface to build Ruby Classes from xsd
class RubyClassBuilder < ClassBuilder


   # implementation of RXSD::ClassBuilder::build
   def build
      # if builtin, just return it
      return @klass if  Parser.is_builtin? @klass

      # need the class name to build class
      return nil    if @klass_name.nil?

      Logger.debug "building class #{@klass}/#{@klass_name} from xsd"

      # determine object's superclass, creating it if need be
      superclass = Object
      unless @base_builder.nil?
        if @base_builder.klass.nil?
          @base_builder = RubyClassBuilder.new(:builder => @base_builder)
          @base_builder.build
        end
        superclass = @base_builder.klass
      end

      # create object
      unless Object.constants.include? @klass_name
        Object.const_set(@klass_name, Class.new(superclass))
      end
      @klass = @klass_name.constantize

      # FIXME should only do this if the klass corresponds to a simple type
      @klass.class_method :from_s do |str|
         new(:superclass_value => superclass.from_s(str))
      end
      @klass.send :define_method, :initialize do |*args|
        super(args[0][:superclass_value]) if args.size > 0 && args[0].has_key?(:superclass_value)
      end

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

end

end
