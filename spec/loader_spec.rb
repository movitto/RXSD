# tests the loader module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe "Loader" do

  it "should load file" do
     File.write("/tmp/rxsd-test", "foobar")
     data = RXSD::Loader.load("file:///tmp/rxsd-test")
     data.should == "foobar"
  end

  it "should load http uri" do
     # uploaded a minimal test to projects.morsi.org
     data = RXSD::Loader.load("http://projects.morsi.org/rxsd/test-schema1.xsd")
     data.should == "foobar\n"
  end

end
