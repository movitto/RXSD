# xml / xsd parsers
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Provides class methods to parse xsd and xml data
class Parser
 private
  def initialize
  end

 public

  # Parse xsd specified by uri or in raw data form into RXSD::XSD::Schema instance
  # args should be a hash w/ optional keys:
  # * :uri location which to load resource from
  # * :raw raw data which to parse
  def self.parse_xsd(args)
     data = Loader.load(args[:uri]) unless args[:uri].nil?
     data = args[:raw]              unless args[:raw].nil?
     Logger.debug "parsing xsd"

     # FIXME validate against xsd's own xsd
     root_xml_node = XML::Node.factory :backend => :libxml, :xml => data
     schema = XSD::Schema.from_xml root_xml_node

     Logger.debug "parsed xsd, resolving relationships"
     Resolver.resolve_nodes schema

     Logger.debug "xsd parsing complete"
     return schema
  end

  # Parse xml specified by uri or in raw data form into RXSD::XSD::SchemaInstance instance
  def self.parse_xml(args)
     data = Loader.load(args[:uri]) unless args[:uri].nil?
     data = args[:raw]              unless args[:raw].nil?
     Logger.debug "parsing xml"

     root_xml_node = XML::Node.factory :backend => :libxml, :xml => data
     schema_instance = SchemaInstance.new :builders => SchemaInstance.builders_from_xml(root_xml_node)

     Logger.debug "xml parsing complete"
     return schema_instance
  end

  # Return true is specified class is builtin, else false
  def self.is_builtin?(builtin_class)
    [Array, String, Boolean, Char, Time, XSDFloat, XSDInteger].include? builtin_class
  end

  # Return ruby class corresponding to builtin type
  def self.parse_builtin_type(builtin_type_name)
    res = nil

    case builtin_type_name
      when "xs:string" then
        res = String
      when "xs:boolean" then
        res = Boolean
      when "xs:decimal" then
        res = XSDFloat
      when "xs:float" then
        res = XSDFloat
      when "xs:double" then
        res = XSDFloat
      when "xs:duration" then
      when "xs:dateTime" then
        res = Time
      when "xs:date" then
        res = Time
      when "xs:gYearMonth" then
        res = Time
      when "xs:gYear" then
        res = Time
      when "xs:gMonthDay" then
        res = Time
      when "xs:gDay" then
        res = Time
      when "xs:gMonth" then
        res = Time
      when "xs:hexBinary" then
      when "xs:base64Binary" then
      when "xs:anyURI" then
      when "xs:QName" then
      when "xs:NOTATION" then
      when "xs:normalizedString"
      when "xs:token"
         res = String # FIXME should be a string derived class, eliminating whitespace
      when "xs:language"
      when "xs:NMTOKEN"
      when "xs:NMTOKENS"
      when "xs:Name"
      when "xs:NCName"
      when "xs:ID"
      when "xs:IDREF"
      when "xs:IDREFS"
      when "xs:ENTITY"
      when "xs:ENTITIES"
      when "xs:integer"
         res = XSDInteger
      when "xs:nonPositiveInteger"
         res = XSDInteger
      when "xs:negativeInteger"
         res = XSDInteger
      when "xs:long"
         res = XSDInteger
      when "xs:int"
         res = XSDInteger
      when "xs:short"
         res = XSDInteger
      when "xs:byte"
         res = Char
      when "xs:nonNegativeInteger"
         res = XSDInteger
      when "xs:unsignedLong"
         res = XSDInteger
      when "xs:unsignedInt"
         res = XSDInteger
      when "xs:unsignedShort"
         res = XSDInteger
      when "xs:unsignedByte"
         res = Char
      when "xs:positiveInteger"
         res = XSDInteger
    end

    return res
  end

end

end
