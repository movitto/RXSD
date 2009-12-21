# xml parsing subsystem
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'rubygems'

# require libxml adapter
require 'libxml_adapter'

module RXSD
module XML

# RXSD XML node interface subclasses must conform to and helper methods
class Node
 
  # should return name of node, eg <foo> => "foo"
  virtual :name

  # return hash of attribute name / values
  virtual :attrs
  
  # should return bool if node has a parent
  virtual :parent?

  # should return this nodes's parent, if any
  virtual :parent
  
  # should return children nodes
  virtual :children

  # should return bool if node only contains text
  virtual :text?

  # should return string contents of text node
  virtual :content

  # should return list of namespaces corresponding to node
  virtual :namespaces

  # should also define class method 'xml_root' that returns a node instance corresponding
  # to the root xml node in provided xml data

  ############################################################################

  # node factory, returns root node corresponding to specified backend and xml data
  def self.factory(args = {})
    backend = args[:backend]
    xml     = args[:xml]
  
    # add additional backend drivers here if desired
    return LibXMLNode.xml_root(xml) if backend == :libxml
    return nil
  end

  # returns root node
  def root
     parent? ? parent.root : self
  end

  # provides accessor interface to related obj, in our case related xsd obj
  attr_accessor :related

  # instantiate all children of provided class type
  def children_objs(klass)
     elements = []
     children.find_all { |c| c.name == klass.tag_name }.each { |c| 
        elements.push(klass.from_xml(c)) }
     return elements
  end

  # instantiate first child of provided class type
  def child_obj(klass)
      return children_objs(klass)[0]
  end

  # return 'value' attribute of all children w/ specified tag
  def child_values(tag_name)
     values = []
     children.find_all { |c| c.name == tag_name }.each { |c| values.push(c.attrs['value']) }
     return values
  end

  # return 'value' attribute of first childw/ specified tag
  def child_value(tag_name)
     return child_values(tag_name)[0]
  end

end

end # module XML
end # module RXSD
