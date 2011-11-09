require "spec_helper"

describe Recurrence do
  let(:enumerator_constant){ RUBY_VERSION > "1.9.0" ? Enumerator : Enumerable::Enumerator }

  it "should require :every option" do
    expect { recurrence({}) }.to raise_error(ArgumentError)
  end

  it "should require valid :every option" do
    expect { recurrence(:every => "invalid") }.to raise_error(ArgumentError)
  end

  it "should require :interval to be greater than zero when provided" do
    expect { recurrence(:every => :day, :interval => 0) }.to raise_error(ArgumentError)
  end

  it "should require :repeat to be greater than zero when provided" do
    expect { recurrence(:every => :day, :repeat => 0) }.to raise_error(ArgumentError)
  end

  it "should return an enumerator when Recurrence#each is called without a block" do
    recurrence(:every => :day).each.should be_instance_of(enumerator_constant)
  end

  it "should return an enumerator when Recurrence#each! is called without a block" do
    recurrence(:every => :day).each!.should be_instance_of(enumerator_constant)
  end

  Recurrence::Event::Monthly::INTERVALS.each do |interval|
    it "should accept valid :interval symbol for monthly recurrence (#{interval[0]})" do
      expect {
        recurrence(:every => :month, :on => 10, :interval => interval[0])
      }.to_not raise_error(ArgumentError)
    end
  end

  Recurrence::Event::Yearly::MONTHS.each do |month_name, month_number|
    it "should accept month as symbol for yearly recurrence (#{month_name})" do
      expect {
        recurrence(:every => :year, :on => [month_name, 10])
      }.to_not raise_error(ArgumentError)
    end
  end

  it "should require month to be a valid symbol for yearly recurrence" do
    expect {
      recurrence(:every => :year, :on => [:invalid, 10])
    }.to raise_error(ArgumentError)
  end

  it "should require :interval to be a valid symbol for monthly recurrence" do
    expect {
      recurrence(:every => :month, :on => 10, :interval => :invalid)
    }.to raise_error(ArgumentError)
  end

  describe ".default_starts_date" do
    it "should return Date.today by default" do
      Recurrence.default_starts_date.should == Date.today
    end

    it "should require only strings and procs" do
      expect {
        Recurrence.default_starts_date = Date.tomorrow
      }.to raise_error(ArgumentError)
    end

    context "when .default_starts_date is reassigned to 'Date.tomorrow' string" do
      before { Recurrence.default_starts_date = "Date.tomorrow" }
      after { Recurrence.default_starts_date = nil }

      it "should return Date.tomorrow" do
        Recurrence.default_starts_date.should == Date.tomorrow
      end

      it "should have effect on generated events" do
        r = Recurrence.new(:every => :day, :until => 3.days.from_now.to_date)
        r.events.first.should == Date.tomorrow
      end
    end

    context "when .default_starts_date is reassigned to lambda { Date.tomorrow } proc" do
      before { Recurrence.default_starts_date = lambda { Date.tomorrow } }
      after { Recurrence.default_starts_date = nil }

      it "should return Date.tomorrow" do
        Recurrence.default_starts_date.should == Date.tomorrow
      end

      it "should have effect on generated events" do
        r = Recurrence.new(:every => :day, :until => 3.days.from_now.to_date)
        r.events.first.should == Date.tomorrow
      end
    end
  end

  context "with daily recurring" do
    it "should recur until limit date" do
      @recurrence = Recurrence.daily
      @recurrence.events[-1].should == Date.parse("2037-12-31")
    end

    it "should repeat until 1 month from now" do
      date = 1.month.from_now
      @recurrence = recurrence(:every => :day, :until => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end

    it "should recur through 1 month from now" do
      date = 1.month.from_now
      @recurrence = recurrence(:every => :day, :through => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end

    it "should start 2 months ago (#{2.months.ago.to_s(:date)})" do
      date = 2.months.ago
      @recurrence = recurrence(:every => :day, :starts => date.to_date)
      @recurrence.events[0].should == date.to_date
      @recurrence.events[1].should == (date + 1.day).to_date
      @recurrence.events[2].should == (date + 2.day).to_date
    end

    it "should start at 2008-03-19 and repeat until 2008-04-24" do
      @recurrence = recurrence(:every => :day, :starts => "2008-03-19", :until => "2008-04-24")
      @recurrence.events[0].to_s.should == "2008-03-19"
      @recurrence.events[1].to_s.should == "2008-03-20"
      @recurrence.events[-1].to_s.should == "2008-04-24"
    end

    it "should start at 2008-03-19 and repeat through 2008-04-24" do
      @recurrence = recurrence(:every => :day, :starts => "2008-03-19", :through => "2008-04-24")
      @recurrence.events[0].to_s.should == "2008-03-19"
      @recurrence.events[1].to_s.should == "2008-03-20"
      @recurrence.events[-1].to_s.should == "2008-04-24"
    end

    it "should use interval" do
      @recurrence = recurrence(:every => :day, :interval => 2, :starts => "2008-09-21")
      @recurrence.events[0].to_s.should == "2008-09-21"
      @recurrence.events[1].to_s.should == "2008-09-23"
      @recurrence.events[2].to_s.should == "2008-09-25"
    end

    it "should use repeat" do
      @recurrence = recurrence(:every => :day, :starts => "2008-09-21", :repeat => 10)
      @recurrence.events.size.should == 10
    end

    it "should have a lacking day if the interval does not match the last day" do
      @recurrence = recurrence(
        :every    => :day,
        :starts   => "2008-03-19",
        :until    => "2008-04-25",
        :interval => 2
      )
      @recurrence.events[-1].to_s.should == "2008-04-24"
    end

    it "should not have a lacking day if the interval does not match the last day" do
      @recurrence = recurrence(
        :every    => :day,
        :starts   => "2008-03-19",
        :through  => "2008-04-25",
        :interval => 2
      )
      @recurrence.events[-1].to_s.should == "2008-04-26"
    end
  end

  context "with weekly recurring" do
    it "should recur until limit date" do
      @recurrence = Recurrence.weekly(:on => :thursday)
      @recurrence.events[-1].should == Date.parse("2037-12-31")
    end

    it "should repeat 6 weeks from now" do
      date = 6.weeks.from_now
      @recurrence = recurrence(:every => :week, :on => date.wday, :until => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end

    it "should repeat through 6 weeks from now" do
      date = 6.weeks.from_now
      @recurrence = recurrence(:every => :week, :on => date.wday, :through => date.to_date)
      @recurrence.events[-1].should == date.to_date
    end

    it "should start 3 months ago (#{3.months.ago.to_s(:date)})" do
      date = 3.months.ago

      @recurrence = recurrence(:every => :week, :on => date.wday, :starts => date.to_date)
      @recurrence.events[0].should == date.to_date
      @recurrence.events[1].should == (date + 1.week).to_date
      @recurrence.events[2].should == (date + 2.weeks).to_date
      @recurrence.events[3].should == (date + 3.weeks).to_date
      @recurrence.events[4].should == (date + 4.weeks).to_date
      @recurrence.events[5].should == (date + 5.weeks).to_date
      @recurrence.events[6].should == (date + 6.weeks).to_date
    end

    it "should start at 2008-02-29 and repeat until 2008-03-14" do
      starts = Date.parse("2008-02-29")
      ends = Date.parse("2008-03-14")

      @recurrence = recurrence(
        :every  => :week,
        :on     => :friday,
        :starts => starts,
        :until  => ends.to_date
      )
      @recurrence.events[0].to_s.should == "2008-02-29"
      @recurrence.events[1].to_s.should == "2008-03-07"
      @recurrence.events[-1].to_s.should == ends.to_s
    end

    it "should start at 2008-02-29 and repeat through 2008-03-14" do
      starts = Date.parse("2008-02-29")
      ends = Date.parse("2008-03-14")

      @recurrence = recurrence(
        :every  => :week,
        :on     => :friday,
        :starts => starts,
        :through=> ends.to_date
      )
      @recurrence.events[0].to_s.should == "2008-02-29"
      @recurrence.events[1].to_s.should == "2008-03-07"
      @recurrence.events[-1].to_s.should == ends.to_s
    end

    it "should use interval" do
      starts = Date.parse("2008-09-21")
      @recurrence = recurrence(
        :every    => :week,
        :on       => starts.wday,
        :interval => 2,
        :starts   => starts,
        :until    => "2009-01-01"
      )
      @recurrence.events[0].to_s.should == "2008-09-21"
      @recurrence.events[1].to_s.should == "2008-10-05"
      @recurrence.events[2].to_s.should == "2008-10-19"
      @recurrence.events[3].to_s.should == "2008-11-02"
      @recurrence.events[4].to_s.should == "2008-11-16"
      @recurrence.events[5].to_s.should == "2008-11-30"
      @recurrence.events[6].to_s.should == "2008-12-14"
    end

    it "should use repeat" do
      starts = Date.parse("2008-09-21")
      @recurrence = recurrence(
        :every    => :week,
        :on       => starts.wday,
        :starts   => starts,
        :until    => "2011-01-01",
        :repeat    => 5
      )
      @recurrence.events.size.should == 5
    end

    it "should occur several times per week" do
      starts = Date.parse("2008-09-21") #=> sunday
      @recurrence = recurrence(
        :every    => :week,
        :on       => [:saturday, :sunday],
        :interval => 2,
        :starts   => starts,
        :until    => "2009-01-01"
      )
      @recurrence.events[0].to_s.should == "2008-09-21"
      @recurrence.events[1].to_s.should == "2008-09-27"
      @recurrence.events[2].to_s.should == "2008-10-05"
      @recurrence.events[3].to_s.should == "2008-10-11"
      @recurrence.events[4].to_s.should == "2008-10-19"
      @recurrence.events[5].to_s.should == "2008-10-25"
      @recurrence.events[6].to_s.should == "2008-11-02"
      @recurrence.events[7].to_s.should == "2008-11-08"

      starts = Date.parse("2008-09-21") #=> sunday
      @recurrence = recurrence(
        :every  => :week,
        :on     => [:monday, :wednesday, :friday],
        :starts => starts,
        :until  => "2009-01-01"
      )
      @recurrence.events[0].to_s.should == "2008-09-22"
      @recurrence.events[1].to_s.should == "2008-09-24"
      @recurrence.events[2].to_s.should == "2008-09-26"
      @recurrence.events[3].to_s.should == "2008-09-29"
      @recurrence.events[4].to_s.should == "2008-10-01"
      @recurrence.events[5].to_s.should == "2008-10-03"
    end

    it "should run until next available saturday" do
      starts = Date.parse("2008-09-21") # => sunday
      @recurrence = recurrence(
        :every  => :week,
        :on     => :saturday,
        :starts => starts,
        :until  => "2009-01-01"
      )
      @recurrence.events[0].to_s.should == "2008-09-27"
    end
  end

  context "with monthly recurring" do
    context "using day" do
      it "should recur until limit date" do
        @recurrence = Recurrence.monthly(:on => 31)
        @recurrence.events[-1].should == Date.parse("2037-12-31")
      end

      it "should repeat until 8 months from now" do
        date = 8.months.from_now
        @recurrence = recurrence(:every => :month, :on => date.day, :until => date.to_date)
        @recurrence.events[-1].should == date.to_date
      end

      it "should repeat through 8 months from now" do
        date = 8.months.from_now
        @recurrence = recurrence(:every => :month, :on => date.day, :through => date.to_date)
        @recurrence.events[-1].should == date.to_date
      end

      it "should start 9 months ago" do
        date = 9.months.ago

        @recurrence = recurrence(:every => :month, :on => date.day, :starts => date.to_date)
        @recurrence.events[0].should == date.to_date
      end

      it "should start at 2008-06-07 and repeat until 2008-11-07" do
        starts = Date.parse("2008-06-07")
        ends = Date.parse("2008-11-07")

        @recurrence = recurrence(
          :every  => :month,
          :on     => starts.day,
          :starts => starts,
          :until  => ends
        )
        @recurrence.events[0].to_s.should == "2008-06-07"
        @recurrence.events[-1].to_s.should == "2008-11-07"
      end

      it "should start at 2008-06-07 and repeat through 2008-11-07" do
        starts = Date.parse("2008-06-07")
        ends = Date.parse("2008-11-07")

        @recurrence = recurrence(
          :every  => :month,
          :on     => starts.day,
          :starts => starts,
          :through=> ends
        )
        @recurrence.events[0].to_s.should == "2008-06-07"
        @recurrence.events[-1].to_s.should == "2008-11-07"
      end

      it "should run until next available 27th" do
        starts = Date.parse("2008-09-28")

        @recurrence = recurrence(
          :every  => :month,
          :on     => 27,
          :starts => starts,
          :until  => "2009-01-01"
        )
        @recurrence.events[0].to_s.should == "2008-10-27"
      end

      it "should run through final available 27th" do
        starts = Date.parse("2008-09-28")

        @recurrence = recurrence(
          :every  => :month,
          :on     => 27,
          :starts => starts,
          :through=> "2009-01-01"
        )
        @recurrence.events[-1].to_s.should == "2009-01-27"
      end

      it "should use interval" do
        starts = Date.parse("2008-01-31")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 31,
          :interval => 2,
          :starts   => starts,
          :until    => "2010-01-01"
        )
        @recurrence.events[0].to_s.should == "2008-01-31"
        @recurrence.events[1].to_s.should == "2008-03-31"
        @recurrence.events[2].to_s.should == "2008-05-31"
        @recurrence.events[3].to_s.should == "2008-07-31"
        @recurrence.events[4].to_s.should == "2008-09-30"
        @recurrence.events[5].to_s.should == "2008-11-30"
        @recurrence.events[6].to_s.should == "2009-01-31"

        starts = Date.parse("2008-01-31")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 29,
          :interval => 3,
          :starts   => starts,
          :until    => "2010-01-01"
        )
        @recurrence.events[0].to_s.should == "2008-04-29"
        @recurrence.events[1].to_s.should == "2008-07-29"
        @recurrence.events[2].to_s.should == "2008-10-29"
        @recurrence.events[3].to_s.should == "2009-01-29"
        @recurrence.events[4].to_s.should == "2009-04-29"
        @recurrence.events[5].to_s.should == "2009-07-29"

        starts = Date.parse("2008-02-29")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 31,
          :interval => 4,
          :starts   => starts,
          :until    => "2010-01-01"
        )
        @recurrence.events[0].to_s.should == "2008-02-29"
        @recurrence.events[1].to_s.should == "2008-06-30"
        @recurrence.events[2].to_s.should == "2008-10-31"
        @recurrence.events[3].to_s.should == "2009-02-28"
      end

      it "should use repeat" do
        starts = Date.parse("2008-01-31")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 31,
          :starts   => starts,
          :until    => "2010-01-01",
          :repeat    => 5
        )
        @recurrence.events.size.should == 5
      end
    end

    context "using weekday" do
      it "should recur until limit date" do
        @recurrence = Recurrence.daily(:on => 5, :weekday => :thursday)
        @recurrence.events[-1].should == Date.parse("2037-12-31")
      end

      it "should use weekday shortcut" do
        @recurrence = Recurrence.daily(:on => 5, :weekday => :thu)
        @recurrence.events[-1].should == Date.parse("2037-12-31")
      end

      it "should repeat until 8 months from now" do
        date = 8.months.from_now
        week = (date.day - 1) / 7 + 1
        @recurrence = recurrence(
          :every   => :month,
          :on      => week,
          :weekday => date.wday,
          :until   => date.to_date
        )
        @recurrence.events[-1].should == date.to_date
      end

      it "should repeat through 8 months from now" do
        date = 8.months.from_now
        week = (date.day - 1) / 7 + 1
        @recurrence = recurrence(
          :every   => :month,
          :on      => week,
          :weekday => date.wday,
          :through => date.to_date
        )
        @recurrence.events[-1].should == date.to_date
      end

      it "should start 9 months ago" do
        date = 9.months.ago
        week = (date.day - 1) / 7 + 1
        @recurrence = recurrence(
          :every   => :month,
          :on      => week,
          :weekday => date.wday,
          :starts  => date.to_date
        )
        @recurrence.events[0].should == date.to_date
      end

      it "should start at 2008-06-07 and repeat until 2008-11-01 (first saturday)" do
        starts = Date.parse("2008-06-07")
        ends = Date.parse("2008-11-01")

        @recurrence = recurrence(
          :every   => :month,
          :on      => :first,
          :weekday => :saturday,
          :starts  => starts,
          :until   => ends
        )
        @recurrence.events[0].to_s.should == "2008-06-07"
        @recurrence.events[-1].to_s.should == "2008-11-01"
      end

      it "should start at 2008-06-29 and repeat until 2008-11-30 (last sunday)" do
        starts = Date.parse("2008-06-29")
        ends = Date.parse("2008-11-30")

        @recurrence = recurrence(
          :every   => :month,
          :on      => :last,
          :weekday => :sunday,
          :starts  => starts,
          :until   => ends
        )
        @recurrence.events[0].to_s.should == "2008-06-29"
        @recurrence.events[-1].to_s.should == "2008-11-30"
      end

      it "should use interval" do
        starts = Date.parse("2009-01-01")
        @recurrence = recurrence(
          :every    => :month,
          :on       => :third,
          :weekday  => :sunday,
          :interval => 2,
          :starts   => starts,
          :until    => "2010-02-01"
        )
        @recurrence.events[0].to_s.should == "2009-01-18"
        @recurrence.events[1].to_s.should == "2009-03-15"
        @recurrence.events[2].to_s.should == "2009-05-17"
        @recurrence.events[3].to_s.should == "2009-07-19"
        @recurrence.events[4].to_s.should == "2009-09-20"
        @recurrence.events[5].to_s.should == "2009-11-15"
        @recurrence.events[6].to_s.should == "2010-01-17"
      end

      it "should use repeat" do
        starts = Date.parse("2009-01-01")
        @recurrence = recurrence(
          :every    => :month,
          :on       => :third,
          :weekday  => :sunday,
          :starts   => starts,
          :until    => "2011-02-01",
          :repeat    => 5
        )
        @recurrence.events.size.should == 5
      end
    end

    context "using interval" do
      before(:each) do
        @starts = Date.parse("2008-09-03")
      end

      it "should use numeric interval" do
        @recurrence = recurrence(:every => :month, :on => 21, :interval => 2, :starts => @starts)
        @recurrence.events[0].to_s.should == "2008-09-21"
        @recurrence.events[1].to_s.should == "2008-11-21"
        @recurrence.events[2].to_s.should == "2009-01-21"
        @recurrence.events[3].to_s.should == "2009-03-21"
      end

      it "should accept monthly symbol" do
        @recurrence = recurrence(
          :every    => :month,
          :on       => 10,
          :starts   => @starts,
          :interval => :monthly
        )
        @recurrence.events[0].to_s.should == "2008-09-10"
        @recurrence.events[1].to_s.should == "2008-10-10"
      end

      it "should accept bimonthly symbol" do
        @recurrence = recurrence(
          :every    => :month,
          :on       => 10,
          :starts   => @starts,
          :interval => :bimonthly
        )
        @recurrence.events[0].to_s.should == "2008-09-10"
        @recurrence.events[1].to_s.should == "2008-11-10"
      end

      it "should accept quarterly symbol" do
        @recurrence = recurrence(
          :every    => :month,
          :on       => 10,
          :starts   => @starts,
          :interval => :quarterly
        )
        @recurrence.events[0].to_s.should == "2008-09-10"
        @recurrence.events[1].to_s.should == "2008-12-10"
      end

      it "should accept semesterly symbol" do
        @recurrence = recurrence(:every => :month, :on => 10, :starts => @starts, :interval => :semesterly)
        @recurrence.events[0].to_s.should == "2008-09-10"
        @recurrence.events[1].to_s.should == "2009-03-10"
      end
    end
  end

  describe "with yearly recurring" do
    it "should recur until limit date" do
      @recurrence = Recurrence.yearly(:on => [12,31])
      @recurrence.events[-1].should == Date.parse("2037-12-31")
    end

    it "should repeat until 7 years from now" do
      date = 7.years.from_now
      @recurrence = recurrence(
        :every => :year,
        :on    => [date.month, date.day],
        :until => date.to_date
      )
      @recurrence.events[-1].should == date.to_date
    end

    it "should repeat through 7 years from now" do
      date = 7.years.from_now
      @recurrence = recurrence(
        :every    => :year,
        :on       => [date.month, date.day],
        :through  => date.to_date
      )
      @recurrence.events[-1].should == date.to_date
    end

    it "should start 2 years ago" do
      date = 2.years.ago
      @recurrence = recurrence(
        :every  => :year,
        :on     => [date.month, date.day],
        :starts => date.to_date
      )
      @recurrence.events[0].should == date.to_date
    end

    it "should start at 2003-06-07 and repeat until 2018-06-07" do
      starts = Date.parse("2003-06-07")
      ends = Date.parse("2018-06-07")

      @recurrence = recurrence(
        :every  => :year,
        :on     => [starts.month, starts.day],
        :starts => starts,
        :until  => ends
      )
      @recurrence.events[0].to_s.should == "2003-06-07"
      @recurrence.events[-1].to_s.should == "2018-06-07"
    end

    it "should start at 2003-06-07 and repeat through 2018-06-07" do
      starts = Date.parse("2003-06-07")
      ends = Date.parse("2018-06-07")

      @recurrence = recurrence(
        :every  => :year,
        :on     => [starts.month, starts.day],
        :starts => starts,
        :through=> ends
      )
      @recurrence.events[0].to_s.should == "2003-06-07"
      @recurrence.events[-1].to_s.should == "2018-06-07"
    end

    it "should use interval" do
      starts = Date.parse("2008-09-21")

      @recurrence = recurrence(
        :every    => :year,
        :on       => [starts.month, starts.day],
        :interval => 2,
        :starts   => starts
      )
      @recurrence.events[0].to_s.should == "2008-09-21"
      @recurrence.events[1].to_s.should == "2010-09-21"
      @recurrence.events[2].to_s.should == "2012-09-21"
      @recurrence.events[3].to_s.should == "2014-09-21"
    end

    it "should use repeat" do
      starts = Date.parse("2008-09-21")

      @recurrence = recurrence(
        :every    => :year,
        :on       => [starts.month, starts.day],
        :starts   => starts,
        :repeat    => 5
      )
      @recurrence.events.size.should == 5
    end

    it "should include the through date when less than a perfect interval" do
      starts = Date.parse("2003-06-07")
      ends = Date.parse("2018-07-12")

      @recurrence = recurrence(
        :every    => :year,
        :on       => [starts.month, starts.day],
        :starts   => starts,
        :through  => ends
      )
      @recurrence.events[-1].to_s.should == '2019-06-07'
    end

    it "should run until next available date when chosen settings are greater than start date" do
      starts = Date.parse("2008-09-03")

      @recurrence = recurrence(:every => :year, :on => [10, 27], :starts => starts)
      @recurrence.events[0].to_s.should == "2008-10-27"
    end

    it "should run until next available date when chosen settings are smaller than start date" do
      starts = Date.parse("2008-09-03")
      @recurrence = recurrence(:every => :year, :on => [7, 1], :starts => starts)
      @recurrence.events[0].to_s.should == "2009-07-01"

      starts = Date.parse("2008-09-03")
      @recurrence = recurrence(:every => :year, :on => [9, 1], :starts => starts)
      @recurrence.events[0].to_s.should == "2009-09-01"
    end
  end

  describe "#options" do
    it "should return passed-in options" do
      @recurrence = recurrence(:every => :day)
      @recurrence.options.should == {:every => :day}
    end
  end

  describe "#include?" do
    it "should include date (day)" do
      @recurrence = recurrence(:every => :day, :starts => "2008-09-30")
      @recurrence.include?("2008-09-30").should be_true
      @recurrence.include?("2008-10-01").should be_true
    end

    it "should include date (week)" do
      @recurrence = recurrence(:every => :week, :on => :thursday, :starts => "2008-09-30")
      @recurrence.include?("2008-09-30").should be_false
      @recurrence.include?("2008-10-02").should be_true

      @recurrence = recurrence(:every => :week, :on => :monday, :starts => "2008-09-29")
      @recurrence.include?("2008-09-29").should be_true
      @recurrence.include?("2008-10-06").should be_true
    end

    it "should include date (month)" do
      @recurrence = recurrence(:every => :month, :on => 10, :starts => "2008-09-30")
      @recurrence.include?("2008-09-30").should be_false
      @recurrence.include?("2008-10-10").should be_true

      @recurrence = recurrence(:every => :month, :on => 10, :starts => "2008-09-10")
      @recurrence.include?("2008-09-10").should be_true
      @recurrence.include?("2008-10-10").should be_true
    end

    it "should include date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => "2008-09-30")
      @recurrence.include?("2009-09-30").should be_false
      @recurrence.include?("2009-06-28").should be_true

      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => "2008-06-28")
      @recurrence.include?("2009-06-28").should be_true
      @recurrence.include?("2009-06-28").should be_true
    end

    it "should not include date when is smaller than starting date (day)" do
      @recurrence = recurrence(:every => :day, :starts => "2008-09-30")
      @recurrence.include?("2008-09-29").should be_false
    end

    it "should not include date when is smaller than starting date (week)" do
      @recurrence = recurrence(:every => :week, :on => :friday, :starts => "2008-09-30")
      @recurrence.include?("2008-09-24").should be_false
    end

    it "should not include date when is smaller than starting date (month)" do
      @recurrence = recurrence(:every => :month, :on => 10, :starts => "2008-09-30")
      @recurrence.include?("2008-09-10").should be_false
    end

    it "should not include date when is smaller than starting date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => "2008-09-30")
      @recurrence.include?("2008-06-28").should be_false
    end

    it "should not include date when is greater than ending date (day)" do
      @recurrence = recurrence(:every => :day, :until => "2008-09-30")
      @recurrence.include?("2008-10-01").should be_false
    end

    it "should not include date when is greater than ending date (week)" do
      @recurrence = recurrence(:every => :week, :on => :friday, :until => "2008-09-30")
      @recurrence.include?("2008-10-03").should be_false
    end

    it "should not include date when is greater than ending date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :until => "2008-09-30")
      @recurrence.include?("2009-06-28").should be_false
    end
  end

  describe "#next" do
    it "should return next date" do
      @recurrence = recurrence(:every => :day)

      @recurrence.next.to_s.should == Date.today.to_s
      @recurrence.next.to_s.should == Date.today.to_s
    end

    it "should return next! date" do
      @recurrence = recurrence(:every => :day)

      @recurrence.next!.to_s.should == Date.today.to_s
      @recurrence.next!.to_s.should == 1.day.from_now.to_date.to_s
      @recurrence.next!.to_s.should == 2.days.from_now.to_date.to_s
      @recurrence.next!.to_s.should == 3.days.from_now.to_date.to_s
    end
  end

  describe "#reset!" do
    it "should reset to the first available date" do
      @recurrence = recurrence(:every => :year, :on => [2, 31], :starts => "2008-01-01")
      @recurrence.next!.to_s.should  == "2008-02-29"
      @recurrence.next!.to_s.should  == "2009-02-28"
      @recurrence.reset!
      @recurrence.next.to_s.should == "2008-02-29"
    end
  end

  describe "event initialization" do
    it "should return the first available date" do
      @recurrence = recurrence(:every => :year, :on => [2, 31], :starts => "2008-01-01")
      @recurrence.next!.to_s.should == "2008-02-29"
      @recurrence.next!.to_s.should == "2009-02-28"
      @recurrence.next!.to_s.should == "2010-02-28"
      @recurrence.next!.to_s.should == "2011-02-28"
      @recurrence.next!.to_s.should == "2012-02-29"
    end
  end

  context "when generating events" do
    before(:each) do
      @recurrence = recurrence(:every => :day, :starts => "2009-01-06", :until => "2009-01-15")
    end

    it "should return starting and ending recurrences" do
      @recurrence.events[0].to_s.should == "2009-01-06"
      @recurrence.events[-1].to_s.should == "2009-01-15"
    end

    it "should reset cache" do
      @recurrence.event.should_receive(:reset!).exactly(3).times
      @recurrence.events(:starts => "2009-01-11")
      @recurrence.events(:until => "2009-01-14")
      @recurrence.events(:starts => "2009-01-11", :until => "2009-01-14")
    end

    it "should return only events greater than starting date" do
      @events = @recurrence.events(:starts => "2009-01-10")
      @events[0].to_s.should == "2009-01-10"
    end

    it "should return only events smaller than until date" do
      @events = @recurrence.events(:until => "2009-01-10")
      @events[0].to_s.should == "2009-01-06"
      @events[-1].to_s.should == "2009-01-10"
    end

    it "should return only events between starting and until date" do
      @events = @recurrence.events(:starts => "2009-01-12", :until => "2009-01-14")
      @events[0].to_s.should == "2009-01-12"
      @events[-1].to_s.should == "2009-01-14"
    end

    it "should not iterate all dates when using until" do
      @events = @recurrence.events(:starts => "2009-01-06", :until => "2009-01-08")
      @recurrence.instance_variable_get("@events").size.should == 3
      @events.size.should == 3
      @events[-1].to_s.should == "2009-01-08"
    end

    context "bug fixes" do
      specify "using name as symbol [http://github.com/fnando/recurrence/issues#issue/3]" do
        expect {
          @recurrence = recurrence(:every => :year, :on => [:jan, 31])
        }.to_not raise_error
      end
    end
  end

  context "with custom handlers" do
    let(:exception_handler) { Proc.new { raise "HANDLED" } }
    let(:shift_handler) { Proc.new { |day, month, year| day += 1 if month % 2 == 0; Date.new(year, month, day) } }

    it "offsets every other month day" do
      r = recurrence(:every => :month, :on => 1, :starts => "2011-01-01", :handler => shift_handler)
      r.events[0].should == Date.new(2011, 1, 1)
      r.events[1].should == Date.new(2011, 2, 2)
      r.events[2].should == Date.new(2011, 3, 1)
      r.events[3].should == Date.new(2011, 4, 2)
    end

    it "raises an exception from the handler" do
      expect { recurrence(:every => :day, :handler => exception_handler) }.to raise_error(RuntimeError, "HANDLED")
    end
  end

  context "with shifting enabled" do
    it "shifts yearly recurrences around February 29" do
      r = recurrence(:every => :year, :starts => "2012-02-29", :on => [2,29], :shift => true)
      r.events[0].should == Date.new(2012, 2, 29)
      r.events[1].should == Date.new(2013, 2, 28)
      r.events[2].should == Date.new(2014, 2, 28)
      r.events[3].should == Date.new(2015, 2, 28)
      r.events[4].should == Date.new(2016, 2, 28)
    end

    it "shifts monthly recurrences around the 31st" do
      r = recurrence(:every => :month, :starts => "2011-01-31", :on => 31, :shift => true)
      r.events[0].should == Date.new(2011, 1, 31)
      r.events[1].should == Date.new(2011, 2, 28)
      r.events[2].should == Date.new(2011, 3, 28)
    end

    it "shifts monthly recurrences around the 30th" do
      r = recurrence(:every => :month, :starts => "2011-01-30", :on => 30, :shift => true)
      r.events[0].should == Date.new(2011, 1, 30)
      r.events[1].should == Date.new(2011, 2, 28)
      r.events[2].should == Date.new(2011, 3, 28)
    end

    it "shifts monthly recurrences around the 29th" do
      r = recurrence(:every => :month, :starts => "2011-01-29", :on => 29, :shift => true)
      r.events[0].should == Date.new(2011, 1, 29)
      r.events[1].should == Date.new(2011, 2, 28)
      r.events[2].should == Date.new(2011, 3, 28)

      r = recurrence(:every => :month, :starts => "2012-01-29", :on => 29, :shift => true)
      r.events[0].should == Date.new(2012, 1, 29)
      r.events[1].should == Date.new(2012, 2, 29)
      r.events[2].should == Date.new(2012, 3, 29)
    end

    it "correctly resets to original day for monthly" do
      r = recurrence(:every => :month, :starts => "2011-01-31", :on => 31, :shift => true)
      r.next!; r.next!
      expect { r.reset! }.to change(r, :next).from(Date.new(2011, 2, 28)).to(Date.new(2011, 1, 31))
    end

    it "correctly resets to original month and day for yearly" do
      r = recurrence(:every => :year, :starts => "2012-02-29", :on => [2,29], :shift => true)
      r.next!; r.next!
      expect { r.reset! }.to change(r, :next).from(Date.new(2013, 2, 28)).to(Date.new(2012, 2, 29))
    end
  end

  private
  def recurrence(options)
    Recurrence.new(options)
  end
end
