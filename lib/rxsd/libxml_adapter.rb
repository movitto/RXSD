
# libxml adapter
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'rubygems'
require 'libxml' # based on libxml

module RXSD
module XML

# class prototype needed :-(
class Node
end

# some additions to libxml xml node interface 
class LibXMLNode < Node

  # implementation of RXSD::XML::Node::xml_root(xml)
  def self.xml_root(xml)
      LibXMLNode.new :node => LibXML::XML::Document.string(xml).root
  end

  # create libxml node adapter w/ specified args, which may include
  #   * :node LibXML::Node to use to satify requests
  def initialize(args = {})
     @node = args[:node]
  end


  # implementation of RXSD::XML::Node.name
  def name 
     @node.name
  end

  # implementation of RXSD::XML::Node.attrs
  def attrs
     @node.attributes.to_h
  end
  
  # implementation of RXSD::XML::Node.parent?
  def parent?
     @node.parent? && @node.parent.class != LibXML::XML::Document
  end

  # implementation of RXSD::XML::Node.parent
  def parent
     parent? ? LibXMLNode.new(:node => @node.parent) : nil
  end

  # implementation of RXSD::XML::Node.children
  def children
     @node.children.collect { |n|
       LibXMLNode.new :node => n
     }
  end

  # implementation of RXSD::XML::Node.text?
  def text?
     @node.text?
  end

  # implementation of RXSD::XML::Node.content
  def content
     @node.content
  end

  # implementation of RXSD::XML::Node.namespaces
  def namespaces
     @node.namespaces
  end

end

end # module XML
end # module RXSD
