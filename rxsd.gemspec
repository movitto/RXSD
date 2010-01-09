# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rxsd}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.1")
  s.author = "Mohammed Morsi"
  s.date = %q{2010-01-09}
  s.description = %q{RXSD is a library to translate xsd schemas and xml implementations into ruby classes/objects}
  s.summary     = %q{RXSD is a library to translate xsd schemas and xml implementations into ruby classes/objects}
  s.email = %q{movitto@yahoo.com}
  s.extra_rdoc_files = [ "README", ]
  s.files = [ "LICENSE", "COPYING", "bin/rxsd-test.rb", "lib/rxsd.rb",
              "lib/rxsd/builder.rb", "lib/rxsd/builtin_types.rb", "lib/rxsd/common.rb",
              "lib/rxsd/exceptions.rb", "lib/rxsd/libxml_adapter.rb", "lib/rxsd/loader.rb",
              "lib/rxsd/parser.rb", "lib/rxsd/resolver.rb", "lib/rxsd/translator.rb",
              "lib/rxsd/xml.rb", "lib/rxsd/builders/ruby_class.rb", 
              "lib/rxsd/builders/ruby_definition.rb", "lib/rxsd/builders/ruby_object.rb",
              "lib/rxsd/xsd/attribute_group.rb", "lib/rxsd/xsd/attribute.rb", 
              "lib/rxsd/xsd/choice.rb", "lib/rxsd/xsd/complex_content.rb", 
              "lib/rxsd/xsd/complex_type.rb", "lib/rxsd/xsd/element.rb", 
              "lib/rxsd/xsd/extension.rb", "lib/rxsd/xsd/group.rb", 
              "lib/rxsd/xsd/list.rb", "lib/rxsd/xsd/restriction.rb", 
              "lib/rxsd/xsd/schema.rb", "lib/rxsd/xsd/sequence.rb", 
              "lib/rxsd/xsd/simple_content.rb", "lib/rxsd/xsd/simple_type.rb"
              ]
  s.has_rdoc = true
  s.homepage = %q{http://projects.morsi.org/RXSD}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.add_dependency 'libxml-ruby', ">= 1.1.3"
  s.add_dependency 'activesupport', ">= 2.3.4"
  #s.add_runtime_dependency "", ""
end
