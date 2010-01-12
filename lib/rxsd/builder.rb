# RXSD builder
#
# responsible for providing  interface to build any output format from XSD metadata
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# base interface and helper methods to build classes in various formats from specified parameters
class ClassBuilder
   # actual class built
   attr_accessor :klass

   # name of class to build
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
      if args.has_key? :builder
        @klass              = args[:builder].klass
        @klass_name         = args[:builder].klass_name
        @associated_builder = args[:builder].associated_builder
        @base_builder       = args[:builder].base_builder
        @attribute_builders = args[:builder].attribute_builders
        @attribute_name     = args[:builder].attribute_name

      else
        @klass = args[:klass]
        @klass_name = args[:klass_name]

        if args.has_key? :base_builder
          @base_builder = args[:base_builder]
        elsif args.has_key?(:base) && !args[:base].nil?
          @base_builder = ClassBuilder.new :klass => args[:base]
        end

        @attribute_builders = []

      end
   end

   # helper method
   def base=(base)
     @base_builder = ClassBuilder.new :klass => base
   end

   # perform a deep copy of builder, takes optional recursive guard
   def clone(cloned = {})
      return cloned[self] if cloned.has_key? self

      cb = ClassBuilder.new
      cloned[self]          = cb
      cb.klass              = @klass
      cb.klass_name         = @klass_name
      cb.attribute_name     = @attribute_name
      cb.associated_builder = @associated_builder.clone(cloned) unless @associated_builder.nil?
      cb.base_builder       = @base_builder.clone(cloned) unless @base_builder.nil?
      @attribute_builders.each { |ab|
         cb.attribute_builders.push ab.clone(cloned) unless ab.nil?
      }
      return cb
   end

   # helper method to get all associated class builders
   def associated(builders = [])
       unless @base_builder.nil? || builders.include?(@base_builder)
         builders.push @base_builder
         builders = @base_builder.associated(builders)
       end

       unless @associated_builder.nil? || builders.include?(@associated_builder)
         builders.push @associated_builder
         builders = @associated_builder.associated(builders)
       end

       @attribute_builders.each { |ab|
         unless ab.nil? || builders.include?(ab)
           builders.push ab
           builders = ab.associated(builders)
         end
       }

       return builders
   end

   # subclasses must implement build method to
   # construct target output type
   virtual :build

end # class ClassBuilder

# base interface and helper methods to build objects in various formats from specified parameters
class ObjectBuilder
   # name of class instance to build
   attr_accessor :tag_name

   # content, for text based data types, will contain text to instantiate object w/
   # TODO might want at some point to store a bool in ClassBuilder (only set to true in SimpleType) indicating
   # that constructed class is a text based type, for verification purposes
   attr_accessor :content

   # actual object built
   attr_accessor :obj

   # hash of attribute names / values to assign to class instance attributes
   attr_accessor :attributes

   # array of children object builders to construct instances and assign to class instance attributes
   attr_accessor :children

   # parent object builder, optionally set
   attr_accessor :parent

   # create a new class builder w/ specified args
   def initialize(args = {})
      if args.has_key? :builder
        @tag_name           = args[:builder].tag_name
        @content            = args[:builder].content
        @obj                = args[:builder].obj
        @attributes         = args[:builder].attributes
        @children           = args[:builder].children
        @parent             = args[:builder].parent

      else
        @tag_name   = args[:tag_name]
        @content    = args[:content]
        @obj        = args[:obj]
        @attributes = args[:attributes]
        @children   = args[:children]
        @parent     = args[:parent]

      end

      @children = [] if @children.nil?
      @attributes = [] if @attributes.nil?
   end

   # subclasses must implement build method to
   # construct target output type, should take one parameter,
   # the schema which to use in object construction
   virtual :build

end


end # module RXSD
