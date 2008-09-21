require "spec"
require "test_notifier/rspec"
require "ruby-debug"
require File.dirname(__FILE__) + "/../lib/recurrence"
alias :doing :lambda

describe "recurrence" do
  it "should require :every option" do
    doing { recurrence({}) }.should raise_error(ArgumentError)
  end
  
  it "should require valid :every option" do
    doing { recurrence(:every => 'invalid') }.should raise_error(ArgumentError)
  end
  
  it "should require :interval to be greater than zero when provided" do
    doing { recurrence(:every => :day, :interval => 0) }.should raise_error(ArgumentError)
  end
  
  describe "- daily" do
    it "should recur until limit date" do
      @recurrence = recurrence(:every => :day)
      @recurrence.items.last.should == Date.parse('2037-12-31')
    end
    
    it "should repeat until 1 month from now" do
      date = 1.month.from_now
      @recurrence = recurrence(:every => :day, :until => date.to_date)
      @recurrence.items.last.should == date.to_date
    end
    
    it "should start 2 months ago" do
      date = 2.months.ago
      @recurrence = recurrence(:every => :day, :starts => date.to_date)
      @recurrence.items.first.should == (date + 1.day).to_date
    end
    
    it "should start at 2008-03-19 and repeat until 2008-04-24" do
      @recurrence = recurrence(:every => :day, :starts => '2008-03-19', :until => '2008-04-24')
      @recurrence.items.first.to_s.should == '2008-03-20'
      @recurrence.items.last.to_s.should == '2008-04-24'
    end
    
    it "should use interval" do
      @recurrence = recurrence(:every => :day, :interval => 2, :starts => '2008-09-21')
      @recurrence.items[0].to_s.should == '2008-09-23'
      @recurrence.items[1].to_s.should == '2008-09-25'
      @recurrence.items[2].to_s.should == '2008-09-27'
    end
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
  
  private
    def recurrence(options)
      Recurrence.new(options)
    end
end