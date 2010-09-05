# rxsd project Rakefile
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# Licensed under the LGPLv3+ http://www.gnu.org/licenses/lgpl.txt

require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'rake/gempackagetask'


GEM_NAME="rxsd"
PKG_VERSION='0.4'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Rake::RDocTask.new do |rd|
    rd.main = "README.rdoc"
    rd.rdoc_dir = "doc/site/api"
    rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

PKG_FILES = FileList['lib/**/*.rb', 'COPYING', 'LICENSE', 'Rakefile', 'README.rdoc', 'spec/**/*.rb' ]

SPEC = Gem::Specification.new do |s|
    s.name = GEM_NAME
    s.version = PKG_VERSION
    s.files = PKG_FILES
    s.executables << 'xsd_to_ruby' << 'rxsd_test'

    s.required_ruby_version = '>= 1.8.1'
    s.required_rubygems_version = Gem::Requirement.new(">= 1.3.3")

    s.add_dependency('libxml-ruby', '~> 1.1.4')
    s.add_development_dependency('rspec', '~> 1.3.0')

    s.author = "Mohammed Morsi"
    s.email = "movitto@yahoo.com"
    s.date = %q{2010-09-04}
    s.description = %q{A library to translate xsd schemas and xml implementations into ruby classes/objects}
    s.summary = %q{A library to translate xsd schemas and xml implementations into ruby classes/objects}
    s.homepage = %q{http://morsi.org/projects/RXSD}
end

Rake::GemPackageTask.new(SPEC) do |pkg|
    pkg.need_tar = true
    pkg.need_zip = true
end
