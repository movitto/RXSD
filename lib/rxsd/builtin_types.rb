# RXSD builtin types
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

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

# ruby doesn't define Boolean class, so we do
# dispatching to TrueClass / FalseClass
class Boolean
  def self.from_s(str)
     str.to_b
  end
end

# ruby doesn't define Char class, so we do
# dispatching to simple string
class Char
  def self.from_s(str)
     str
  end
end

class Integer
  def self.from_s(str)
     str.to_i
  end
end

class Float
  def self.from_s(str)
     str.to_f
  end
end

class Array
  def self.from_s(str, item_type)
     arr = []
     str.split.each { |i|
       arr.push item_type.from_s(i)
     }
     return arr
  end
end
