# RXSD builtin types
#
# Here we add some functionality to some basic
# Ruby types and define some of our own.
#
# Each type must be able to be instantiated with
# no arguments as well as from a string string parameter
# (exception is made in the case of Array)
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'date'

# Array, String, Time can be instantiated as is

class Array
  # arrays take addition parameter when instantiating from
  # string, the item type which to instantiate array elements w/
  def self.from_s(str, item_type)
     arr = []
     str.split.each { |i|
       arr.push item_type.from_s(i)
     }
     return arr
  end
end

class String
  # convert string to boolean
  def to_b
    return true if self == true || self =~ /^true$/i
    return false if self == false || self.nil? || self =~ /^false$/i
    raise ArgumentError, "invalid value for Boolean: \"#{self}\""
  end

  def self.from_s(str)
     str
  end
end

class Time
  def self.from_s(str)
     return Time.parse(str)
  end
end

# ruby doesn't define Char class, so we dispatch to string
class Char < String
end

# Since we can't create new instances of Integer, Float,
# etc subclasses, we use the delegate module
# http://codeidol.com/other/rubyckbk/Numbers/Simulating-a-Subclass-of-Fixnum/
require 'delegate'

class XSDInteger < DelegateClass(::Integer)
  def self.from_s(str)
     str.to_i
  end
end

class XSDFloat < DelegateClass(::Float)
  def self.from_s(str)
     str.to_f
  end
end

# ruby doesn't define Boolean class, so we define one ourselves
class Boolean
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
