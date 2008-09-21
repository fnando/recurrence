require "spec"
require "test_notifier/rspec"
require File.dirname(__FILE__) + "/../lib/recurrence"
alias :doing :lambda

describe "recurrence" do
  it "should require :every option" do
    doing { Recurrence.new({}) }.should raise_error(ArgumentError)
  end
  
  it "should require valid :every option" do
    doing { Recurrence.new(:every => 'invalid') }.should raise_error(ArgumentError)
  end
  
  it "should require :interval to be greater than zero when provided" do
    doing { Recurrence.new(:every => :day, :interval => 0) }.should raise_error(ArgumentError)
  end
  
  describe "- daily" do
  end
  
  describe "- weekly" do
  end
  
  describe "- monthly" do
  end
  
  describe "- yearly" do
  end
  
  describe "- inclusion" do
  end
  
  describe "- iteration" do
  end
end