# rxsd project Rakefile
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

#task :default => :test

task(:test) do
   desc "Run tests"
   require 'test/all_tests'
end

task :rdoc do
  desc "Create RDoc documentation"
  system "rdoc --title 'rxsd documentation' lib/"
end

task :create_gem do
  desc "Create a new gem"
  system "gem build rxsd.gemspec"
end

task :dist do
  desc "Create a source tarball"
  system "mkdir ruby-rxsd-0.1.0 && \
          cp -R conf/ bin/ db/ lib/ test/ ruby-rxsd-0.1.0/ && \
          tar czvf rxsd.tgz ruby-rxsd-0.1.0 && \
          rm -rf ruby-rxsd-0.1.0"
end
