# xml / xsd parsers
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# provides class methods to parse xsd and xml data
class Parser
 private
  def initialize
  end

 public

  # parse xsd specified by uri or in raw data form into RXSD::XSD::Schema instance
  # args should be a hash w/ optional keys:
  #   * :uri location which to load resource from
  #   * :raw raw data which to parse
  def self.parse_xsd(args)
     data = Loader.load(args[:uri]) unless args[:uri].nil?
     data = args[:raw]              unless args[:raw].nil?
     Logger.debug "parsing following xsd: #{data}" 

     # FIXME validate against xsd's own xsd
     root_xml_node = XML::Node.factory :backend => :libxml, :xml => data
     schema = XSD::Schema.from_xml root_xml_node

     Logger.debug "parsed xsd, resolving relationships"
     Resolver.resolve_nodes schema

     Logger.debug "xsd parsing complete"
     return schema
  end

  # parse xml specified by uri or in raw data form into RXSD::XSD::SchemaInstance instance
  def self.parse_xml(args)
     data = Loader.load(args[:uri]) unless args[:uri].nil?
     data = args[:raw]              unless args[:raw].nil?
     Logger.debug "parsing following xml: #{data}"

     root_xml_node = XML::Node.factory :backend => :libxml, :xml => data
     schema_instance = SchemaInstance.new :builders => SchemaInstance.builders_from_xml(root_xml_node)

     Logger.debug "xml parsing complete"
     return schema_instance
  end

  # return true is specified class is builtin, else false
  def self.is_builtin?(builtin_class)
    [Array, String, Boolean, Char, Float, Integer].include? builtin_class
  end

  # return ruby class corresponding to builting type
  def self.parse_builtin_type(builtin_type_name)
    res = nil

    case builtin_type_name
      when "xs:string":
        res = String
      when "xs:boolean":
        res = Boolean
      when "xs:decimal":
        res = Float
      when "xs:float":
        res = Float
      when "xs:double":
        res = Float
      when "xs:duration":
      when "xs:dateTime":
      when "xs:date":
      when "xs:gYearMonth":
      when "xs:gYear":
      when "xs:gMonthDay":
      when "xs:gDay":
      when "xs:gMonth":
      when "xs:hexBinary":
      when "xs:base64Binary":
      when "xs:anyURI":
      when "xs:QName":
      when "xs:NOTATION":
      when "xs:normalizedString"
      when "xs:token"
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
         res = Integer
      when "xs:nonPositiveInteger"
         res = Integer
      when "xs:negativeInteger"
         res = Integer
      when "xs:long"
         res = Integer
      when "xs:int"
         res = Integer
      when "xs:short"
         res = Integer
      when "xs:byte"
         res = Char
      when "xs:nonNegativeInteger"
         res = Integer
      when "xs:unsignedLong"
         res = Integer
      when "xs:unsignedInt"
         res = Integer
      when "xs:unsignedShort"
         res = Integer
      when "xs:unsignedByte"
         res = Char
      when "xs:positiveInteger"
         res = Integer
    end

    return res
  end

end

end
