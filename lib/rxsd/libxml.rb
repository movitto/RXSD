# libxml adapter
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'rubygems'
require 'libxml' # based on libxml

# some additions to libxml xml node interface 
class LibXML::XML::Node 

  # This would be an easy place to make xml backend configurable,
  #   eg use rexml as an alternative.
  # Just override all the following methods:

  #def name 
  #  should return name of node, eg <foo> => "foo"
  #end

  # return hash of attribute name / values
  def attrs
     attributes.to_h
  end
  
  # def parent?
  #   # should return bool if node has a parent
  #end

  #def parent
  #   # should return this nodes's parent, if any
  #end
  
  # def children
  #   # should return children nodes
  #end

  # def text?
  #   # should return bool if node only contains text
  #end

  # return root node
  def root
     parent? ? parent.root : self
  end

  # provide accessor interface to related obj, in our case related xsd obj
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
