# rxsd project Rakefile
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# Licensed under the LGPLv3+ http://www.gnu.org/licenses/lgpl.txt

require 'rdoc/task'
require 'rspec'



desc "Run all specs"
Spec::Rake::SpecTask.new('rspec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "doc/site/api"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
