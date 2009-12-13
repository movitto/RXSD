# loads and runs all tests for the rxsd project
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test/unit'
require 'mocha'

require File.dirname(__FILE__) + '/../lib/rxsd'

include RXSD
include RXSD::XSD

require 'test/loader_test'
require 'test/parser_test'
require 'test/resolver_test'
require 'test/builder_test'
require 'test/translator_test'
#Dir['**/*_test.rb'].each { |test_case| require test_case }
