# RXSD Ruby Class builder
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Implements the RXSD::ClassBuilder interface to build Ruby Classes from xsd
class RubyClassBuilder < ClassBuilder


   # implementation of RXSD::ClassBuilder::build
   def build
      # return if already built
      return @klass unless @klass.nil?

      # need the class name to build class
      return nil    if @klass_name.nil?

      # return if we can find constant corresponding to class name
      if Object.constants.include? @klass_name
        @klass = @klass_name.constantize
        return @klass
      end

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

      # create class
      Object.const_set(@klass_name, Class.new(superclass))
      @klass = @klass_name.constantize

      # FIXME should only do this if the klass corresponds to a simple type
      @klass.class_method :from_s do |str|
            new(:superclass_value => superclass.from_s(str))
      end
      @klass.send :define_method, :initialize do |*args|
        args = args.first || Hash.new
        if !args.nil? && args.has_key?(:superclass_value)
           if Parser.is_builtin? superclass
              super(args[:superclass_value])
           else
              super(:superclass_value => args[:superclass_value])
           end
        end
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
