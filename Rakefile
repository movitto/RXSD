# rxsd project Rakefile
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# Licensed under the LGPLv3+ http://www.gnu.org/licenses/lgpl.txt

require 'rdoc/task'
require "rspec/core/rake_task"

desc "Run all specs"
RSpec::Core::RakeTask.new('rspec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "doc/site/api"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
