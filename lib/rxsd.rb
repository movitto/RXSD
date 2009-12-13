# include all rxsd modules
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

lib = File.dirname(__FILE__)

require 'rubygems'
require 'motel'

require lib + '/rxsd/common'
require lib + '/rxsd/libxml'
require lib + '/rxsd/loader'
require lib + '/rxsd/resolver'
require lib + '/rxsd/parser'
require lib + '/rxsd/builder'
require lib + '/rxsd/translator'

Dir[lib + '/rxsd/xsd/*.rb'].each { |xsd_module| require xsd_module }
