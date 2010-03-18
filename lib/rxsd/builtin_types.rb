# RXSD builtin types
#
# Here we add some functionality to some basic
# Ruby types and define some of our own.
#
# Each type must be able to be instantiated with
# no arguments as well as from a string string parameter
# (exception is made in the case of Array)
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'date'

# Array, String, Time can be instantiated as is

class Array
  # Convert string to array and return.
  # * str should be the string encoded array
  # * item_type should be the class on which to invoke from_s on each array item
  def self.from_s(str, item_type)
     arr = []
     str.split.each { |i|
       arr.push item_type.from_s(i)
     }
     return arr
  end
end

class String
  # Convert string to boolean
  def to_b
    return true if self == true || self =~ /^true$/i
    return false if self == false || self.nil? || self =~ /^false$/i
    raise ArgumentError, "invalid value for Boolean: \"#{self}\""
  end

  # Convert string to string (just return str)
  def self.from_s(str)
     str
  end

  # Helper to convert string to array of specified type.
  def to_a(args = {})
     arr = []
     item_type = args[:type]
     delim     = args.has_key?(:delim) ? args[:delim] : ' '
     split(delim).collect { |item| arr.push(item_type.from_s(item)) }
     return arr
  end
end

class Time
  # Convert string to Time and return 
  def self.from_s(str)
     return Time.parse(str)
  end
end

# Ruby doesn't define a Char class, so we define one here and dispatch to string
class Char < String
end

require 'delegate'

# Since we can't create new instances of Integer subclasses,
# we use the delegate module.
# http://codeidol.com/other/rubyckbk/Numbers/Simulating-a-Subclass-of-Fixnum/
class XSDInteger < DelegateClass(::Integer)

  # Convert string to integer and return
  def self.from_s(str)
     str.to_i
  end

end

# Since we can't create new instances of Float subclasses,
# we use the delegate module.
# http://codeidol.com/other/rubyckbk/Numbers/Simulating-a-Subclass-of-Fixnum/
class XSDFloat < DelegateClass(::Float)

  # Convert string to float and return
  def self.from_s(str)
     str.to_f
  end

end

# Ruby doesn't define a Boolean class, so we define one ourselves
class Boolean

  # Convert string to boolean and return
  def self.from_s(str)
     str.to_b
  end

  def initialize(val=false)
     @val = val
  end

  def nil?
     return !@val
  end
end
