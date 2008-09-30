require "rubygems"
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
  
  Recurrence::INTERVALS.each do |interval|
    it "should accept valid :interval symbol for monthly recurrence (#{interval[0]})" do
      doing { recurrence(:every => :month, :on => 10, :interval => interval[0]) }.should_not raise_error(ArgumentError)
    end
  end
  
  it "should require :interval to be a valid symbol for monthly recurrence" do
    doing { recurrence(:every => :month, :on => 10, :interval => :invalid) }.should raise_error(ArgumentError)
  end
  
  describe "- daily" do
    it "should recur until limit date" do
      @recurrence = recurrence(:every => :day)
      @recurrence.events[-1].should == Date.parse('2037-12-31')
    end
    
    it "should repeat until 1 month from now" do
      date = 1.month.from_now
      @recurrence = recurrence(:every => :day, :until => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end
    
    it "should start 2 months ago" do
      date = 2.months.ago
      @recurrence = recurrence(:every => :day, :starts => date.to_date)
      @recurrence.events[0].should == date.to_date
    end
    
    it "should start at 2008-03-19 and repeat until 2008-04-24" do
      @recurrence = recurrence(:every => :day, :starts => '2008-03-19', :until => '2008-04-24')
      @recurrence.events[0].to_s.should == '2008-03-19'
      @recurrence.events[-1].to_s.should == '2008-04-24'
    end
    
    it "should use interval" do
      @recurrence = recurrence(:every => :day, :interval => 2, :starts => '2008-09-21')
      @recurrence.events[0].to_s.should == '2008-09-21'
      @recurrence.events[1].to_s.should == '2008-09-23'
      @recurrence.events[2].to_s.should == '2008-09-25'
    end
  end
  
  describe "- weekly" do
    it "should recur until limit date" do
      @recurrence = recurrence(:every => :week, :on => :thursday)
      @recurrence.events[-1].should == Date.parse('2037-12-31')
    end
    
    it "should repeat 6 weeks from now" do
      date = 6.weeks.from_now
      @recurrence = recurrence(:every => :week, :on => date.wday, :until => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end
    
    it "should start 3 months ago" do
      date = 3.months.ago
      @recurrence = recurrence(:every => :week, :on => date.wday, :starts => date.to_date)
      @recurrence.events[0].should == date.to_date
    end
    
    it "should start at 2008-02-29 and repeat until 2008-03-14" do
      starts = Date.parse('2008-02-29')
      ends = starts + 6.weeks
      
      @recurrence = recurrence(:every => :week, :on => starts.wday, :starts => starts, :until => ends.to_date)
      @recurrence.events[0].to_s.should == '2008-02-29'
      @recurrence.events[-1].to_s.should == ends.to_s
    end
    
    it "should use interval" do
      starts = Date.parse('2008-09-21')
      @recurrence = recurrence(:every => :week, :on => starts.wday, :interval => 2, :starts => starts)
      @recurrence.events[0].to_s.should == '2008-09-21'
      @recurrence.events[1].to_s.should == '2008-10-05'
      @recurrence.events[2].to_s.should == '2008-10-19'
    end
    
    it "should run until next available saturday" do
      starts = Date.parse('2008-09-21') # => sunday
      @recurrence = recurrence(:every => :week, :on => :saturday, :starts => starts)
      @recurrence.events[0].to_s.should == '2008-09-27'
    end
  end
  
  describe "- monthly" do
    it "should recur until limit date" do
      @recurrence = recurrence(:every => :month, :on => 31)
      @recurrence.events[-1].should == Date.parse('2037-12-31')
    end
    
    it "should repeat until 8 months from now" do
      date = 8.months.from_now
      @recurrence = recurrence(:every => :month, :on => date.day, :until => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end
    
    it "should start 9 months ago" do
      date = 9.months.ago
      @recurrence = recurrence(:every => :month, :on => date.day, :starts => date.to_date)
      @recurrence.events[0].should == date.to_date
    end
    
    it "should start at 2008-06-07 and repeat until 2008-11-07" do
      starts = Date.parse('2008-06-07')
      ends = Date.parse('2008-11-07')
      
      @recurrence = recurrence(:every => :month, :on => starts.day, :starts => starts, :until => ends)
      @recurrence.events[0].to_s.should == '2008-06-07'
      @recurrence.events[-1].to_s.should == '2008-11-07'
    end
    
    it "should run until next available 27th" do
      starts = Date.parse('2008-09-03')
      
      @recurrence = recurrence(:every => :month, :on => 27, :starts => starts)
      @recurrence.events[0].to_s.should == '2008-09-27'
    end
    
    describe "interval" do
      before(:each) do
        @starts = Date.parse('2008-09-03')
      end
      
      it "should use numeric interval" do
        @recurrence = recurrence(:every => :month, :on => 21, :interval => 2, :starts => @starts)
        @recurrence.events[0].to_s.should == '2008-09-21'
        @recurrence.events[1].to_s.should == '2008-11-21'
        @recurrence.events[2].to_s.should == '2009-01-21'
        @recurrence.events[3].to_s.should == '2009-03-21'
      end
      
      it "should accept monthly symbol" do
        @recurrence = recurrence(:every => :month, :on => 10, :starts => @starts, :interval => :monthly)
        @recurrence.events[0].to_s.should == '2008-09-10'
        @recurrence.events[1].to_s.should == '2008-10-10'
      end
      
      it "should accept bimonthly symbol" do
        @recurrence = recurrence(:every => :month, :on => 10, :starts => @starts, :interval => :bimonthly)
        @recurrence.events[0].to_s.should == '2008-09-10'
        @recurrence.events[1].to_s.should == '2008-11-10'
      end
      
      it "should accept quarterly symbol" do
        @recurrence = recurrence(:every => :month, :on => 10, :starts => @starts, :interval => :quarterly)
        @recurrence.events[0].to_s.should == '2008-09-10'
        @recurrence.events[1].to_s.should == '2008-12-10'
      end
      
      it "should accept semesterly symbol" do
        @recurrence = recurrence(:every => :month, :on => 10, :starts => @starts, :interval => :semesterly)
        @recurrence.events[0].to_s.should == '2008-09-10'
        @recurrence.events[1].to_s.should == '2009-03-10'
      end
    end
  end
  
  describe "- yearly" do
    it "should recur until limit date" do
      @recurrence = recurrence(:every => :year, :on => [12,31])
      @recurrence.events[-1].should == Date.parse('2037-12-31')
    end
    
    it "should repeat until 7 years from now" do
      date = 7.years.from_now
      @recurrence = recurrence(:every => :year, :on => [date.month, date.day], :until => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end
    
    it "should start 2 years ago" do
      date = 2.years.ago
      @recurrence = recurrence(:every => :year, :on => [date.month, date.day], :starts => date.to_date)
      @recurrence.events[0].should == date.to_date
    end
    
    it "should start at 2003-06-07 and repeat until 2018-06-07" do
      starts = Date.parse('2003-06-07')
      ends = Date.parse('2018-06-07')
      
      @recurrence = recurrence(:every => :year, :on => [starts.month, starts.day], :starts => starts, :until => ends)
      @recurrence.events[0].to_s.should == '2003-06-07'
      @recurrence.events[-1].to_s.should == '2018-06-07'
    end
    
    it "should use interval" do
      starts = Date.parse('2008-09-21')
      
      @recurrence = recurrence(:every => :year, :on => [starts.month, starts.day], :interval => 2, :starts => starts)
      @recurrence.events[0].to_s.should == '2008-09-21'
      @recurrence.events[1].to_s.should == '2010-09-21'
      @recurrence.events[2].to_s.should == '2012-09-21'
      @recurrence.events[3].to_s.should == '2014-09-21'
    end
    
    it "should run until next available date when chosen settings are greater than start date" do
      starts = Date.parse('2008-09-03')
      
      @recurrence = recurrence(:every => :year, :on => [10, 27], :starts => starts)
      @recurrence.events[0].to_s.should == '2008-10-27'
    end
    
    it "should run until next available date when chosen settings are smaller than start date" do
      starts = Date.parse('2008-09-03')
      
      @recurrence = recurrence(:every => :year, :on => [7, 1], :starts => starts)
      @recurrence.events[0].to_s.should == '2009-07-01'
    end
  end
  
  describe "include" do
    it "should include date (day)" do
      @recurrence = recurrence(:every => :day, :starts => '2008-09-30')
      @recurrence.include?('2008-10-01').should be_true
    end
    
    it "should include date (week)" do
      @recurrence = recurrence(:every => :week, :on => :thursday, :starts => '2008-09-30')
      @recurrence.include?('2008-10-02').should be_true
    end
    
    it "should include date (month)" do
      @recurrence = recurrence(:every => :month, :on => 10, :starts => '2008-09-30')
      @recurrence.include?('2008-10-10').should be_true
    end
    
    it "should include date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => '2008-09-30')
      @recurrence.include?('2009-06-28').should be_true
    end
    
    it "should not include date when is smaller than starting date (day)" do
      @recurrence = recurrence(:every => :day, :starts => '2008-09-30')
      @recurrence.include?('2008-09-29').should be_false
    end
    
    it "should not include date when is smaller than starting date (week)" do
      @recurrence = recurrence(:every => :week, :on => :friday, :starts => '2008-09-30')
      @recurrence.include?('2008-09-24').should be_false
    end
    
    it "should not include date when is smaller than starting date (month)" do
      @recurrence = recurrence(:every => :month, :on => 10, :starts => '2008-09-30')
      @recurrence.include?('2008-09-10').should be_false
    end
    
    it "should not include date when is smaller than starting date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => '2008-09-30')
      @recurrence.include?('2008-06-28').should be_false
    end
    
    it "should not include date when is greater than ending date (day)" do
      @recurrence = recurrence(:every => :day, :until => '2008-09-30')
      @recurrence.include?('2008-10-01').should be_false
    end
    
    it "should not include date when is greater than ending date (week)" do
      @recurrence = recurrence(:every => :week, :on => :friday, :until => '2008-09-30')
      @recurrence.include?('2008-10-03').should be_false
    end
    
    it "should not include date when is greater than ending date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :until => '2008-09-30')
      @recurrence.include?('2009-06-28').should be_false
    end
  end
  
  private
    def recurrence(options)
      Recurrence.new(options)
    end
end