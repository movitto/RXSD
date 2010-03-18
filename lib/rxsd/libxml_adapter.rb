# libxml adapter
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'rubygems'
require 'libxml' # based on libxml

module RXSD
module XML

class Node ; end
class Namespace ; end

# Some additions to the libxml namespace interface
class LibXMLNamespace < Namespace
   def initialize(args = {})
      @ns = args[:ns]
   end

   # Implementation of RXSD::XML::Namespace.prefix
   def prefix
      @ns.prefix
   end

   # Implementation of RXSD::XML::Namespace.href
   def href
      @ns.href
   end

   # Implementation of RXSD::XML::Namespace.to_s
   def to_s
      @ns.to_s
   end
end

# Some additions to libxml xml node interface 
class LibXMLNode < Node

  # Implementation of RXSD::XML::Node::xml_root(xml)
  def self.xml_root(xml)
      LibXMLNode.new :node => LibXML::XML::Document.string(xml).root
  end

  # Create libxml node adapter w/ specified args, which may include
  # * :node LibXML::Node to use to satify requests
  def initialize(args = {})
     @node = args[:node]
     @parent = args[:parent] if args.has_key? :parent

     @attributes = @node.attributes.to_h

     @children = []
     @node.children.find_all { |n| !n.text? }.each { |n|
       @children << LibXMLNode.new(:node => n, :parent => self)
     }
     
     @namespaces = []
     @node.namespaces.each { |ns| 
        @namespaces << LibXMLNamespace.new(:ns => ns)
     }
  end


  # Implementation of RXSD::XML::Node.name
  def name 
     @node.name
  end

  # Implementation of RXSD::XML::Node.attrs
  def attrs
     @attributes
  end
  
  # Implementation of RXSD::XML::Node.parent?
  def parent?
     @node.parent? && @node.parent.class != LibXML::XML::Document
  end

  # FIXME in parent and children don't instantiate new objects, instead use some shared registry

  # Implementation of RXSD::XML::Node.parent
  def parent
     parent? ? @parent : nil
  end

  # Implementation of RXSD::XML::Node.children
  def children
     @children
  end

  # Implementation of RXSD::XML::Node.text?. 
  # See #content method as well
  def text?
     @node.text? || (@node.children.size == 1 && @node.children[0].text?)
  end

  # Implementation of RXSD::XML::Node.content
  # See text? method as well
  def content
     return nil unless text?
     @node.content if @node.text?
     @node.children[0].content
  end

  # Implementation of RXSD::XML::Node.namespaces
  def namespaces
     @namespaces
  end

end

end # module XML
end # module RXSD
