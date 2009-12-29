# Simple rxsd test utility
#
# Usage rxsd-test.rb uri-to-schema uri-to-xml-instance
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'lib/rxsd'

if ARGV.size < 2
  puts "missing required arguments"
  exit
end

xsd_uri = ARGV[0]
xml_uri = ARGV[1]

schema = RXSD::Parser.parse_xsd :uri => xsd_uri
#def disp_child(obj)
#  if obj.respond_to? 'children'
#  puts "#{obj}"
#    obj.children.each { |c|
#      disp_child c
#    }
#  end
#end
#disp_child(schema)

puts "=======Classes======="
classes = schema.to :ruby_classes
puts classes.collect{ |cl| !cl.nil? ? (cl.to_s + " < " + cl.superclass.to_s) : ""}.sort.join("\n")

puts "=======Tags======="
puts schema.tags.collect { |n,cb| n + ": " + cb.to_s + ": " + (cb.nil? ? "ncb" : cb.klass_name.to_s + "-" + cb.klass.to_s) }.sort.join("\n")

puts "=======Objects======="
data = RXSD::Parser.parse_xml :uri => xml_uri
objs = data.to :ruby_objects, :schema => schema
objs.each {  |obj|
  puts "#{obj}"
}
