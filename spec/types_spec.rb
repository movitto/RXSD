# rxsd types tests
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe "RXSD Types" do

  # FIXME DateTime

  it "should convert string to/from bool" do
     "true".to_b.should be_true
     "false".to_b.should be_false
     lambda {
        "foobar".to_b
     }.should raise_error(ArgumentError)

     String.from_s("money").should == "money"
  end

  it "should convert bool to/from string" do
     Boolean.from_s("true").should be_true
     Boolean.from_s("false").should be_false
  end

  it "should convert char to/from string" do
     Char.from_s("c").should == "c"
  end

  it "should convert int to/from string" do
     XSDInteger.from_s("123").should == 123
  end

  it "should convert float to/from string" do
     XSDFloat.from_s("4.25").should == 4.25
  end

  it "should convert array to/from string" do
     arr = Array.from_s "4 9 50 123", XSDInteger
     arr.size.should == 4
     arr.include?(4).should be_true
     arr.include?(9).should be_true
     arr.include?(50).should be_true
     arr.include?(123).should be_true
  end
end
