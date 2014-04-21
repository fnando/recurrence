require "spec_helper"

describe Recurrence do
  let(:enumerator_constant){ RUBY_VERSION > "1.9.0" ? Enumerator : Enumerable::Enumerator }

  it "requires :every option" do
    expect { recurrence({}) }.to raise_error(ArgumentError)
  end

  it "requires valid :every option" do
    expect { recurrence(:every => "invalid") }.to raise_error(ArgumentError)
  end

  it "requires :interval to be greater than zero when provided" do
    expect { recurrence(:every => :day, :interval => 0) }.to raise_error(ArgumentError)
  end

  it "requires :repeat to be greater than zero when provided" do
    expect { recurrence(:every => :day, :repeat => 0) }.to raise_error(ArgumentError)
  end

  it "returns an enumerator when Recurrence#each is called without a block" do
    expect(recurrence(:every => :day).each).to be_instance_of(enumerator_constant)
  end

  it "returns an enumerator when Recurrence#each! is called without a block" do
    expect(recurrence(:every => :day).each!).to be_instance_of(enumerator_constant)
  end

  Recurrence::Event::Monthly::INTERVALS.each do |interval|
    it "accepts valid :interval symbol for monthly recurrence (#{interval[0]})" do
      expect {
        recurrence(:every => :month, :on => 10, :interval => interval[0])
      }.to_not raise_error
    end
  end

  Recurrence::Event::Yearly::MONTHS.each do |month_name, month_number|
    it "accepts month as symbol for yearly recurrence (#{month_name})" do
      expect {
        recurrence(:every => :year, :on => [month_name, 10])
      }.to_not raise_error
    end
  end

  it "requires month to be a valid symbol for yearly recurrence" do
    expect {
      recurrence(:every => :year, :on => [:invalid, 10])
    }.to raise_error(ArgumentError)
  end

  it "requires :interval to be a valid symbol for monthly recurrence" do
    expect {
      recurrence(:every => :month, :on => 10, :interval => :invalid)
    }.to raise_error(ArgumentError)
  end

  describe ".default_starts_date" do
    it "returns Date.today by default" do
      expect(Recurrence.default_starts_date).to eq(Date.today)
    end

    it "requires only strings and procs" do
      expect {
        Recurrence.default_starts_date = Date.tomorrow
      }.to raise_error(ArgumentError)
    end

    context "when .default_starts_date is reassigned to 'Date.tomorrow' string" do
      before { Recurrence.default_starts_date = "Date.tomorrow" }
      after { Recurrence.default_starts_date = nil }

      it "returns Date.tomorrow" do
        expect(Recurrence.default_starts_date).to eq(Date.tomorrow)
      end

      it "has effect on generated events" do
        r = Recurrence.new(:every => :day, :until => 3.days.from_now.to_date)
        expect(r.events.first).to eq(Date.tomorrow)
      end
    end

    context "when .default_starts_date is reassigned to lambda { Date.tomorrow } proc" do
      before { Recurrence.default_starts_date = lambda { Date.tomorrow } }
      after { Recurrence.default_starts_date = nil }

      it "returns Date.tomorrow" do
        expect(Recurrence.default_starts_date).to eq(Date.tomorrow)
      end

      it "has effect on generated events" do
        r = Recurrence.new(:every => :day, :until => 3.days.from_now.to_date)
        expect(r.events.first).to eq(Date.tomorrow)
      end
    end
  end

  context "with daily recurring" do
    it "recurs until limit date" do
      @recurrence = Recurrence.daily
      expect(@recurrence.events[-1]).to eq(Date.parse("2037-12-31"))
    end

    it "repeats until 1 month from now" do
      date = 1.month.from_now
      @recurrence = recurrence(:every => :day, :until => date.to_date)
      expect(@recurrence.events[-1]).to eq(date.to_date)
    end

    it "recurs through 1 month from now" do
      date = 1.month.from_now
      @recurrence = recurrence(:every => :day, :through => date.to_date)
      expect(@recurrence.events[-1]).to eq(date.to_date)
    end

    it "starts 2 months ago (#{2.months.ago.to_s(:date)})" do
      date = 2.months.ago
      @recurrence = recurrence(:every => :day, :starts => date.to_date)
      expect(@recurrence.events[0]).to eq(date.to_date)
      expect(@recurrence.events[1]).to eq((date + 1.day).to_date)
      expect(@recurrence.events[2]).to eq((date + 2.day).to_date)
    end

    it "starts at 2008-03-19 and repeat until 2008-04-24" do
      @recurrence = recurrence(:every => :day, :starts => "2008-03-19", :until => "2008-04-24")
      expect(@recurrence.events[0].to_s).to eq("2008-03-19")
      expect(@recurrence.events[1].to_s).to eq("2008-03-20")
      expect(@recurrence.events[-1].to_s).to eq("2008-04-24")
    end

    it "starts at 2008-03-19 and repeat through 2008-04-24" do
      @recurrence = recurrence(:every => :day, :starts => "2008-03-19", :through => "2008-04-24")
      expect(@recurrence.events[0].to_s).to eq("2008-03-19")
      expect(@recurrence.events[1].to_s).to eq("2008-03-20")
      expect(@recurrence.events[-1].to_s).to eq("2008-04-24")
    end

    it "uses interval" do
      @recurrence = recurrence(:every => :day, :interval => 2, :starts => "2008-09-21")
      expect(@recurrence.events[0].to_s).to eq("2008-09-21")
      expect(@recurrence.events[1].to_s).to eq("2008-09-23")
      expect(@recurrence.events[2].to_s).to eq("2008-09-25")
    end

    it "uses repeat" do
      @recurrence = recurrence(:every => :day, :starts => "2008-09-21", :repeat => 10)
      expect(@recurrence.events.size).to eq(10)
    end

    it "has a lacking day if the interval does not match the last day" do
      @recurrence = recurrence(
        :every    => :day,
        :starts   => "2008-03-19",
        :until    => "2008-04-25",
        :interval => 2
      )
      expect(@recurrence.events[-1].to_s).to eq("2008-04-24")
    end

    it "doesn't have a lacking day if the interval does not match the last day" do
      @recurrence = recurrence(
        :every    => :day,
        :starts   => "2008-03-19",
        :through  => "2008-04-25",
        :interval => 2
      )
      expect(@recurrence.events[-1].to_s).to eq("2008-04-26")
    end

    it "uses except" do
      @recurrence = Recurrence.daily(:except => Date.tomorrow)
      expect(@recurrence.events.include?(Date.tomorrow)).to be_falsey
      expect(@recurrence.events.include?(Date.tomorrow+1.day)).to be_truthy
    end
  end

  context "with weekly recurring" do
    it "recurs until limit date" do
      @recurrence = Recurrence.weekly(:on => :thursday)
      expect(@recurrence.events[-1]).to eq(Date.parse("2037-12-31"))
    end

    it "repeats 6 weeks from now" do
      date = 6.weeks.from_now
      @recurrence = recurrence(:every => :week, :on => date.wday, :until => date.to_date)
      expect(@recurrence.events[-1]).to eq(date.to_date)
    end

    it "repeats through 6 weeks from now" do
      date = 6.weeks.from_now
      @recurrence = recurrence(:every => :week, :on => date.wday, :through => date.to_date)
      expect(@recurrence.events[-1]).to eq(date.to_date)
    end

    it "starts 3 months ago (#{3.months.ago.to_s(:date)})" do
      date = 3.months.ago

      @recurrence = recurrence(:every => :week, :on => date.wday, :starts => date.to_date)
      expect(@recurrence.events[0]).to eq(date.to_date)
      expect(@recurrence.events[1]).to eq((date + 1.week).to_date)
      expect(@recurrence.events[2]).to eq((date + 2.weeks).to_date)
      expect(@recurrence.events[3]).to eq((date + 3.weeks).to_date)
      expect(@recurrence.events[4]).to eq((date + 4.weeks).to_date)
      expect(@recurrence.events[5]).to eq((date + 5.weeks).to_date)
      expect(@recurrence.events[6]).to eq((date + 6.weeks).to_date)
    end

    it "starts at 2008-02-29 and repeat until 2008-03-14" do
      starts = Date.parse("2008-02-29")
      ends = Date.parse("2008-03-14")

      @recurrence = recurrence(
        :every  => :week,
        :on     => :friday,
        :starts => starts,
        :until  => ends.to_date
      )
      expect(@recurrence.events[0].to_s).to eq("2008-02-29")
      expect(@recurrence.events[1].to_s).to eq("2008-03-07")
      expect(@recurrence.events[-1].to_s).to eq(ends.to_s)
    end

    it "starts at 2008-02-29 and repeat through 2008-03-14" do
      starts = Date.parse("2008-02-29")
      ends = Date.parse("2008-03-14")

      @recurrence = recurrence(
        :every  => :week,
        :on     => :friday,
        :starts => starts,
        :through=> ends.to_date
      )
      expect(@recurrence.events[0].to_s).to eq("2008-02-29")
      expect(@recurrence.events[1].to_s).to eq("2008-03-07")
      expect(@recurrence.events[-1].to_s).to eq(ends.to_s)
    end

    it "uses interval" do
      starts = Date.parse("2008-09-21")
      @recurrence = recurrence(
        :every    => :week,
        :on       => starts.wday,
        :interval => 2,
        :starts   => starts,
        :until    => "2009-01-01"
      )
      expect(@recurrence.events[0].to_s).to eq("2008-09-21")
      expect(@recurrence.events[1].to_s).to eq("2008-10-05")
      expect(@recurrence.events[2].to_s).to eq("2008-10-19")
      expect(@recurrence.events[3].to_s).to eq("2008-11-02")
      expect(@recurrence.events[4].to_s).to eq("2008-11-16")
      expect(@recurrence.events[5].to_s).to eq("2008-11-30")
      expect(@recurrence.events[6].to_s).to eq("2008-12-14")
    end

    it "uses repeat" do
      starts = Date.parse("2008-09-21")
      @recurrence = recurrence(
        :every    => :week,
        :on       => starts.wday,
        :starts   => starts,
        :until    => "2011-01-01",
        :repeat    => 5
      )
      expect(@recurrence.events.size).to eq(5)
    end

    it "occurs several times per week" do
      starts = Date.parse("2008-09-21") #=> sunday
      @recurrence = recurrence(
        :every    => :week,
        :on       => [:saturday, :sunday],
        :interval => 2,
        :starts   => starts,
        :until    => "2009-01-01"
      )
      expect(@recurrence.events[0].to_s).to eq("2008-09-21")
      expect(@recurrence.events[1].to_s).to eq("2008-09-27")
      expect(@recurrence.events[2].to_s).to eq("2008-10-05")
      expect(@recurrence.events[3].to_s).to eq("2008-10-11")
      expect(@recurrence.events[4].to_s).to eq("2008-10-19")
      expect(@recurrence.events[5].to_s).to eq("2008-10-25")
      expect(@recurrence.events[6].to_s).to eq("2008-11-02")
      expect(@recurrence.events[7].to_s).to eq("2008-11-08")

      starts = Date.parse("2008-09-21") #=> sunday
      @recurrence = recurrence(
        :every  => :week,
        :on     => [:monday, :wednesday, :friday],
        :starts => starts,
        :until  => "2009-01-01"
      )
      expect(@recurrence.events[0].to_s).to eq("2008-09-22")
      expect(@recurrence.events[1].to_s).to eq("2008-09-24")
      expect(@recurrence.events[2].to_s).to eq("2008-09-26")
      expect(@recurrence.events[3].to_s).to eq("2008-09-29")
      expect(@recurrence.events[4].to_s).to eq("2008-10-01")
      expect(@recurrence.events[5].to_s).to eq("2008-10-03")
    end

    it "runs until next available saturday" do
      starts = Date.parse("2008-09-21") # => sunday
      @recurrence = recurrence(
        :every  => :week,
        :on     => :saturday,
        :starts => starts,
        :until  => "2009-01-01"
      )
      expect(@recurrence.events[0].to_s).to eq("2008-09-27")
    end

    it "uses except" do
      date = 6.weeks.from_now
      @recurrence = recurrence(:every => :week, :on => date.wday, :except => 2.weeks.from_now.to_date)
      expect(@recurrence.events.include?(1.week.from_now.to_date)).to be_truthy
      expect(@recurrence.events.include?(2.weeks.from_now.to_date)).to be_falsey
    end
  end

  context "with monthly recurring" do
    context "using day" do
      it "recurs until limit date" do
        @recurrence = Recurrence.monthly(:on => 31)
        expect(@recurrence.events[-1]).to eq(Date.parse("2037-12-31"))
      end

      it "repeats until 8 months from now" do
        date = 8.months.from_now
        @recurrence = recurrence(:every => :month, :on => date.day, :until => date.to_date)
        expect(@recurrence.events[-1]).to eq(date.to_date)
      end

      it "repeats through 8 months from now" do
        date = 8.months.from_now
        @recurrence = recurrence(:every => :month, :on => date.day, :through => date.to_date)
        expect(@recurrence.events[-1]).to eq(date.to_date)
      end

      it "starts 9 months ago" do
        date = 9.months.ago

        @recurrence = recurrence(:every => :month, :on => date.day, :starts => date.to_date)
        expect(@recurrence.events[0]).to eq(date.to_date)
      end

      it "starts at 2008-06-07 and repeat until 2008-11-07" do
        starts = Date.parse("2008-06-07")
        ends = Date.parse("2008-11-07")

        @recurrence = recurrence(
          :every  => :month,
          :on     => starts.day,
          :starts => starts,
          :until  => ends
        )
        expect(@recurrence.events[0].to_s).to eq("2008-06-07")
        expect(@recurrence.events[-1].to_s).to eq("2008-11-07")
      end

      it "starts at 2008-06-07 and repeat through 2008-11-07" do
        starts = Date.parse("2008-06-07")
        ends = Date.parse("2008-11-07")

        @recurrence = recurrence(
          :every  => :month,
          :on     => starts.day,
          :starts => starts,
          :through=> ends
        )
        expect(@recurrence.events[0].to_s).to eq("2008-06-07")
        expect(@recurrence.events[-1].to_s).to eq("2008-11-07")
      end

      it "runs until next available 27th" do
        starts = Date.parse("2008-09-28")

        @recurrence = recurrence(
          :every  => :month,
          :on     => 27,
          :starts => starts,
          :until  => "2009-01-01"
        )
        expect(@recurrence.events[0].to_s).to eq("2008-10-27")
      end

      it "runs through final available 27th" do
        starts = Date.parse("2008-09-28")

        @recurrence = recurrence(
          :every  => :month,
          :on     => 27,
          :starts => starts,
          :through=> "2009-01-01"
        )
        expect(@recurrence.events[-1].to_s).to eq("2009-01-27")
      end

      it "uses interval" do
        starts = Date.parse("2008-01-31")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 31,
          :interval => 2,
          :starts   => starts,
          :until    => "2010-01-01"
        )
        expect(@recurrence.events[0].to_s).to eq("2008-01-31")
        expect(@recurrence.events[1].to_s).to eq("2008-03-31")
        expect(@recurrence.events[2].to_s).to eq("2008-05-31")
        expect(@recurrence.events[3].to_s).to eq("2008-07-31")
        expect(@recurrence.events[4].to_s).to eq("2008-09-30")
        expect(@recurrence.events[5].to_s).to eq("2008-11-30")
        expect(@recurrence.events[6].to_s).to eq("2009-01-31")

        starts = Date.parse("2008-01-31")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 29,
          :interval => 3,
          :starts   => starts,
          :until    => "2010-01-01"
        )
        expect(@recurrence.events[0].to_s).to eq("2008-04-29")
        expect(@recurrence.events[1].to_s).to eq("2008-07-29")
        expect(@recurrence.events[2].to_s).to eq("2008-10-29")
        expect(@recurrence.events[3].to_s).to eq("2009-01-29")
        expect(@recurrence.events[4].to_s).to eq("2009-04-29")
        expect(@recurrence.events[5].to_s).to eq("2009-07-29")

        starts = Date.parse("2008-02-29")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 31,
          :interval => 4,
          :starts   => starts,
          :until    => "2010-01-01"
        )
        expect(@recurrence.events[0].to_s).to eq("2008-02-29")
        expect(@recurrence.events[1].to_s).to eq("2008-06-30")
        expect(@recurrence.events[2].to_s).to eq("2008-10-31")
        expect(@recurrence.events[3].to_s).to eq("2009-02-28")
      end

      it "uses repeat" do
        starts = Date.parse("2008-01-31")
        @recurrence = recurrence(
          :every    => :month,
          :on       => 31,
          :starts   => starts,
          :until    => "2010-01-01",
          :repeat    => 5
        )
        expect(@recurrence.events.size).to eq(5)
      end

      it "uses except" do
        @recurrence = recurrence(:every => :month, :on => Date.today.day, :except => 8.months.from_now.to_date)
        expect(@recurrence.events.include?(7.months.from_now.to_date)).to be_truthy
        expect(@recurrence.events.include?(8.months.from_now.to_date)).to be_falsey
      end
    end

    context "using weekday" do
      it "recurs until limit date" do
        @recurrence = Recurrence.daily(:on => 5, :weekday => :thursday)
        expect(@recurrence.events[-1]).to eq(Date.parse("2037-12-31"))
      end

      it "uses weekday shortcut" do
        @recurrence = Recurrence.daily(:on => 5, :weekday => :thu)
        expect(@recurrence.events[-1]).to eq(Date.parse("2037-12-31"))
      end

      it "repeats until 8 months from now" do
        date = 8.months.from_now
        week = (date.day - 1) / 7 + 1
        @recurrence = recurrence(
          :every   => :month,
          :on      => week,
          :weekday => date.wday,
          :until   => date.to_date
        )
        expect(@recurrence.events[-1]).to eq(date.to_date)
      end

      it "repeats through 8 months from now" do
        date = 8.months.from_now
        week = (date.day - 1) / 7 + 1
        @recurrence = recurrence(
          :every   => :month,
          :on      => week,
          :weekday => date.wday,
          :through => date.to_date
        )
        expect(@recurrence.events[-1]).to eq(date.to_date)
      end

      it "starts 9 months ago" do
        date = 9.months.ago
        week = (date.day - 1) / 7 + 1
        @recurrence = recurrence(
          :every   => :month,
          :on      => week,
          :weekday => date.wday,
          :starts  => date.to_date
        )
        expect(@recurrence.events[0]).to eq(date.to_date)
      end

      it "starts at 2008-06-07 and repeat until 2008-11-01 (first saturday)" do
        starts = Date.parse("2008-06-07")
        ends = Date.parse("2008-11-01")

        @recurrence = recurrence(
          :every   => :month,
          :on      => :first,
          :weekday => :saturday,
          :starts  => starts,
          :until   => ends
        )
        expect(@recurrence.events[0].to_s).to eq("2008-06-07")
        expect(@recurrence.events[-1].to_s).to eq("2008-11-01")
      end

      it "starts at 2008-06-29 and repeat until 2008-11-30 (last sunday)" do
        starts = Date.parse("2008-06-29")
        ends = Date.parse("2008-11-30")

        @recurrence = recurrence(
          :every   => :month,
          :on      => :last,
          :weekday => :sunday,
          :starts  => starts,
          :until   => ends
        )
        expect(@recurrence.events[0].to_s).to eq("2008-06-29")
        expect(@recurrence.events[-1].to_s).to eq("2008-11-30")
      end

      it "uses interval" do
        starts = Date.parse("2009-01-01")
        @recurrence = recurrence(
          :every    => :month,
          :on       => :third,
          :weekday  => :sunday,
          :interval => 2,
          :starts   => starts,
          :until    => "2010-02-01"
        )
        expect(@recurrence.events[0].to_s).to eq("2009-01-18")
        expect(@recurrence.events[1].to_s).to eq("2009-03-15")
        expect(@recurrence.events[2].to_s).to eq("2009-05-17")
        expect(@recurrence.events[3].to_s).to eq("2009-07-19")
        expect(@recurrence.events[4].to_s).to eq("2009-09-20")
        expect(@recurrence.events[5].to_s).to eq("2009-11-15")
        expect(@recurrence.events[6].to_s).to eq("2010-01-17")
      end

      it "uses repeat" do
        starts = Date.parse("2009-01-01")
        @recurrence = recurrence(
          :every    => :month,
          :on       => :third,
          :weekday  => :sunday,
          :starts   => starts,
          :until    => "2011-02-01",
          :repeat    => 5
        )
        expect(@recurrence.events.size).to eq(5)
      end
    end

    context "using interval" do
      before(:each) do
        @starts = Date.parse("2008-09-03")
      end

      it "uses numeric interval" do
        @recurrence = recurrence(:every => :month, :on => 21, :interval => 2, :starts => @starts)
        expect(@recurrence.events[0].to_s).to eq("2008-09-21")
        expect(@recurrence.events[1].to_s).to eq("2008-11-21")
        expect(@recurrence.events[2].to_s).to eq("2009-01-21")
        expect(@recurrence.events[3].to_s).to eq("2009-03-21")
      end

      it "accepts monthly symbol" do
        @recurrence = recurrence(
          :every    => :month,
          :on       => 10,
          :starts   => @starts,
          :interval => :monthly
        )
        expect(@recurrence.events[0].to_s).to eq("2008-09-10")
        expect(@recurrence.events[1].to_s).to eq("2008-10-10")
      end

      it "accepts bimonthly symbol" do
        @recurrence = recurrence(
          :every    => :month,
          :on       => 10,
          :starts   => @starts,
          :interval => :bimonthly
        )
        expect(@recurrence.events[0].to_s).to eq("2008-09-10")
        expect(@recurrence.events[1].to_s).to eq("2008-11-10")
      end

      it "accepts quarterly symbol" do
        @recurrence = recurrence(
          :every    => :month,
          :on       => 10,
          :starts   => @starts,
          :interval => :quarterly
        )
        expect(@recurrence.events[0].to_s).to eq("2008-09-10")
        expect(@recurrence.events[1].to_s).to eq("2008-12-10")
      end

      it "accepts semesterly symbol" do
        @recurrence = recurrence(:every => :month, :on => 10, :starts => @starts, :interval => :semesterly)
        expect(@recurrence.events[0].to_s).to eq("2008-09-10")
        expect(@recurrence.events[1].to_s).to eq("2009-03-10")
      end
    end
  end

  describe "with yearly recurring" do
    it "recurs until limit date" do
      @recurrence = Recurrence.yearly(:on => [12,31])
      expect(@recurrence.events[-1]).to eq(Date.parse("2037-12-31"))
    end

    it "repeats until 7 years from now" do
      date = 7.years.from_now
      @recurrence = recurrence(
        :every => :year,
        :on    => [date.month, date.day],
        :until => date.to_date
      )
      expect(@recurrence.events[-1]).to eq(date.to_date)
    end

    it "repeats through 7 years from now" do
      date = 7.years.from_now
      @recurrence = recurrence(
        :every    => :year,
        :on       => [date.month, date.day],
        :through  => date.to_date
      )
      expect(@recurrence.events[-1]).to eq(date.to_date)
    end

    it "starts 2 years ago" do
      date = 2.years.ago
      @recurrence = recurrence(
        :every  => :year,
        :on     => [date.month, date.day],
        :starts => date.to_date
      )
      expect(@recurrence.events[0]).to eq(date.to_date)
    end

    it "starts at 2003-06-07 and repeat until 2018-06-07" do
      starts = Date.parse("2003-06-07")
      ends = Date.parse("2018-06-07")

      @recurrence = recurrence(
        :every  => :year,
        :on     => [starts.month, starts.day],
        :starts => starts,
        :until  => ends
      )
      expect(@recurrence.events[0].to_s).to eq("2003-06-07")
      expect(@recurrence.events[-1].to_s).to eq("2018-06-07")
    end

    it "starts at 2003-06-07 and repeat through 2018-06-07" do
      starts = Date.parse("2003-06-07")
      ends = Date.parse("2018-06-07")

      @recurrence = recurrence(
        :every  => :year,
        :on     => [starts.month, starts.day],
        :starts => starts,
        :through=> ends
      )
      expect(@recurrence.events[0].to_s).to eq("2003-06-07")
      expect(@recurrence.events[-1].to_s).to eq("2018-06-07")
    end

    it "uses interval" do
      starts = Date.parse("2008-09-21")

      @recurrence = recurrence(
        :every    => :year,
        :on       => [starts.month, starts.day],
        :interval => 2,
        :starts   => starts
      )
      expect(@recurrence.events[0].to_s).to eq("2008-09-21")
      expect(@recurrence.events[1].to_s).to eq("2010-09-21")
      expect(@recurrence.events[2].to_s).to eq("2012-09-21")
      expect(@recurrence.events[3].to_s).to eq("2014-09-21")
    end

    it "uses repeat" do
      starts = Date.parse("2008-09-21")

      @recurrence = recurrence(
        :every    => :year,
        :on       => [starts.month, starts.day],
        :starts   => starts,
        :repeat    => 5
      )
      expect(@recurrence.events.size).to eq(5)
    end

    it "includes the through date when less than a perfect interval" do
      starts = Date.parse("2003-06-07")
      ends = Date.parse("2018-07-12")

      @recurrence = recurrence(
        :every    => :year,
        :on       => [starts.month, starts.day],
        :starts   => starts,
        :through  => ends
      )
      expect(@recurrence.events[-1].to_s).to eq('2019-06-07')
    end

    it "runs until next available date when chosen settings are greater than start date" do
      starts = Date.parse("2008-09-03")

      @recurrence = recurrence(:every => :year, :on => [10, 27], :starts => starts)
      expect(@recurrence.events[0].to_s).to eq("2008-10-27")
    end

    it "runs until next available date when chosen settings are smaller than start date" do
      starts = Date.parse("2008-09-03")
      @recurrence = recurrence(:every => :year, :on => [7, 1], :starts => starts)
      expect(@recurrence.events[0].to_s).to eq("2009-07-01")

      starts = Date.parse("2008-09-03")
      @recurrence = recurrence(:every => :year, :on => [9, 1], :starts => starts)
      expect(@recurrence.events[0].to_s).to eq("2009-09-01")
    end

    it "uses except" do
      @recurrence = Recurrence.yearly(:on => [12,31], :except => "#{Time.now.year+3}-12-31")

      expect(@recurrence.events.include?("#{Time.now.year+2}-12-31".to_date)).to be_truthy
      expect(@recurrence.events.include?("#{Time.now.year+3}-12-31".to_date)).to be_falsey
    end
  end

  context "with except", :focus => true do
    it "accepts only valid date strings or Dates" do
      expect { recurrence(:except => :symbol) }.to raise_error(ArgumentError)
      expect { recurrence(:except => "invalid") }.to raise_error(ArgumentError)
    end

    it "skips day specified in except" do
      @recurrence = recurrence(:every => :day, :except => Date.tomorrow)
      expect(@recurrence.include?(Date.today)).to be_truthy
      expect(@recurrence.include?(Date.tomorrow)).to be_falsey
      expect(@recurrence.include?(Date.tomorrow+1.day)).to be_truthy
    end

    it "skips multiple days specified in except" do
      @recurrence = recurrence(:every => :day, :except => [Date.tomorrow, "2012-02-29"])
      expect(@recurrence.include?(Date.today)).to be_truthy
      expect(@recurrence.include?(Date.tomorrow)).to be_falsey
      expect(@recurrence.include?("2012-02-29")).to be_falsey
    end
  end

  describe "#options" do
    it "returns passed-in options" do
      @recurrence = recurrence(:every => :day)
      expect(@recurrence.options).to eq({:every => :day})
    end
  end

  describe "#include?" do
    it "includes date (day)" do
      @recurrence = recurrence(:every => :day, :starts => "2008-09-30")
      expect(@recurrence.include?("2008-09-30")).to be_truthy
      expect(@recurrence.include?("2008-10-01")).to be_truthy
    end

    it "includes date (week)" do
      @recurrence = recurrence(:every => :week, :on => :thursday, :starts => "2008-09-30")
      expect(@recurrence.include?("2008-09-30")).to be_falsey
      expect(@recurrence.include?("2008-10-02")).to be_truthy

      @recurrence = recurrence(:every => :week, :on => :monday, :starts => "2008-09-29")
      expect(@recurrence.include?("2008-09-29")).to be_truthy
      expect(@recurrence.include?("2008-10-06")).to be_truthy
    end

    it "includes date (month)" do
      @recurrence = recurrence(:every => :month, :on => 10, :starts => "2008-09-30")
      expect(@recurrence.include?("2008-09-30")).to be_falsey
      expect(@recurrence.include?("2008-10-10")).to be_truthy

      @recurrence = recurrence(:every => :month, :on => 10, :starts => "2008-09-10")
      expect(@recurrence.include?("2008-09-10")).to be_truthy
      expect(@recurrence.include?("2008-10-10")).to be_truthy
    end

    it "includes date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => "2008-09-30")
      expect(@recurrence.include?("2009-09-30")).to be_falsey
      expect(@recurrence.include?("2009-06-28")).to be_truthy

      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => "2008-06-28")
      expect(@recurrence.include?("2009-06-28")).to be_truthy
      expect(@recurrence.include?("2009-06-28")).to be_truthy
    end

    it "doesn't include date when is smaller than starting date (day)" do
      @recurrence = recurrence(:every => :day, :starts => "2008-09-30")
      expect(@recurrence.include?("2008-09-29")).to be_falsey
    end

    it "doesn't include date when is smaller than starting date (week)" do
      @recurrence = recurrence(:every => :week, :on => :friday, :starts => "2008-09-30")
      expect(@recurrence.include?("2008-09-24")).to be_falsey
    end

    it "doesn't include date when is smaller than starting date (month)" do
      @recurrence = recurrence(:every => :month, :on => 10, :starts => "2008-09-30")
      expect(@recurrence.include?("2008-09-10")).to be_falsey
    end

    it "doesn't include date when is smaller than starting date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :starts => "2008-09-30")
      expect(@recurrence.include?("2008-06-28")).to be_falsey
    end

    it "doesn't include date when is greater than ending date (day)" do
      @recurrence = recurrence(:every => :day, :until => "2008-09-30")
      expect(@recurrence.include?("2008-10-01")).to be_falsey
    end

    it "doesn't include date when is greater than ending date (week)" do
      @recurrence = recurrence(:every => :week, :on => :friday, :until => "2008-09-30")
      expect(@recurrence.include?("2008-10-03")).to be_falsey
    end

    it "doesn't include date when is greater than ending date (year)" do
      @recurrence = recurrence(:every => :year, :on => [6,28], :until => "2008-09-30")
      expect(@recurrence.include?("2009-06-28")).to be_falsey
    end
  end

  describe "#next" do
    it "returns next date" do
      @recurrence = recurrence(:every => :day)

      expect(@recurrence.next.to_s).to eq(Date.today.to_s)
      expect(@recurrence.next.to_s).to eq(Date.today.to_s)
    end

    it "returns next! date" do
      @recurrence = recurrence(:every => :day)

      expect(@recurrence.next!.to_s).to eq(Date.today.to_s)
      expect(@recurrence.next!.to_s).to eq(1.day.from_now.to_date.to_s)
      expect(@recurrence.next!.to_s).to eq(2.days.from_now.to_date.to_s)
      expect(@recurrence.next!.to_s).to eq(3.days.from_now.to_date.to_s)
    end
  end

  describe "#reset!" do
    it "resets to the first available date" do
      @recurrence = recurrence(:every => :year, :on => [2, 31], :starts => "2008-01-01")
      expect(@recurrence.next!.to_s).to  eq("2008-02-29")
      expect(@recurrence.next!.to_s).to  eq("2009-02-28")
      @recurrence.reset!
      expect(@recurrence.next.to_s).to eq("2008-02-29")
    end
  end

  describe "event initialization" do
    it "returns the first available date" do
      @recurrence = recurrence(:every => :year, :on => [2, 31], :starts => "2008-01-01")
      expect(@recurrence.next!.to_s).to eq("2008-02-29")
      expect(@recurrence.next!.to_s).to eq("2009-02-28")
      expect(@recurrence.next!.to_s).to eq("2010-02-28")
      expect(@recurrence.next!.to_s).to eq("2011-02-28")
      expect(@recurrence.next!.to_s).to eq("2012-02-29")
    end
  end

  context "when generating events" do
    before(:each) do
      @recurrence = recurrence(:every => :day, :starts => "2009-01-06", :until => "2009-01-15")
    end

    it "returns starting and ending recurrences" do
      expect(@recurrence.events[0].to_s).to eq("2009-01-06")
      expect(@recurrence.events[-1].to_s).to eq("2009-01-15")
    end

    it "resets cache" do
      expect(@recurrence.event).to receive(:reset!).exactly(3).times
      @recurrence.events(:starts => "2009-01-11")
      @recurrence.events(:until => "2009-01-14")
      @recurrence.events(:starts => "2009-01-11", :until => "2009-01-14")
    end

    it "returns only events greater than starting date" do
      @events = @recurrence.events(:starts => "2009-01-10")
      expect(@events[0].to_s).to eq("2009-01-10")
    end

    it "returns only events smaller than until date" do
      @events = @recurrence.events(:until => "2009-01-10")
      expect(@events[0].to_s).to eq("2009-01-06")
      expect(@events[-1].to_s).to eq("2009-01-10")
    end

    it "returns only events between starting and until date" do
      @events = @recurrence.events(:starts => "2009-01-12", :until => "2009-01-14")
      expect(@events[0].to_s).to eq("2009-01-12")
      expect(@events[-1].to_s).to eq("2009-01-14")
    end

    it "doesn't iterate all dates when using until" do
      @events = @recurrence.events(:starts => "2009-01-06", :until => "2009-01-08")
      expect(@recurrence.instance_variable_get("@events").size).to eq(3)
      expect(@events.size).to eq(3)
      expect(@events[-1].to_s).to eq("2009-01-08")
    end

    context "bug fixes" do
      it "uses name as symbol [issue#3]" do
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
      expect(r.events[0]).to eq(Date.new(2011, 1, 1))
      expect(r.events[1]).to eq(Date.new(2011, 2, 2))
      expect(r.events[2]).to eq(Date.new(2011, 3, 1))
      expect(r.events[3]).to eq(Date.new(2011, 4, 2))
    end

    it "raises an exception from the handler" do
      expect { recurrence(:every => :day, :handler => exception_handler) }.to raise_error(RuntimeError, "HANDLED")
    end
  end

  context "with shifting enabled" do
    it "shifts yearly recurrences around February 29" do
      r = recurrence(:every => :year, :starts => "2012-02-29", :on => [2,29], :shift => true)
      expect(r.events[0]).to eq(Date.new(2012, 2, 29))
      expect(r.events[1]).to eq(Date.new(2013, 2, 28))
      expect(r.events[2]).to eq(Date.new(2014, 2, 28))
      expect(r.events[3]).to eq(Date.new(2015, 2, 28))
      expect(r.events[4]).to eq(Date.new(2016, 2, 28))
    end

    it "shifts monthly recurrences around the 31st" do
      r = recurrence(:every => :month, :starts => "2011-01-31", :on => 31, :shift => true)
      expect(r.events[0]).to eq(Date.new(2011, 1, 31))
      expect(r.events[1]).to eq(Date.new(2011, 2, 28))
      expect(r.events[2]).to eq(Date.new(2011, 3, 28))
    end

    it "shifts monthly recurrences around the 30th" do
      r = recurrence(:every => :month, :starts => "2011-01-30", :on => 30, :shift => true)
      expect(r.events[0]).to eq(Date.new(2011, 1, 30))
      expect(r.events[1]).to eq(Date.new(2011, 2, 28))
      expect(r.events[2]).to eq(Date.new(2011, 3, 28))
    end

    it "shifts monthly recurrences around the 29th" do
      r = recurrence(:every => :month, :starts => "2011-01-29", :on => 29, :shift => true)
      expect(r.events[0]).to eq(Date.new(2011, 1, 29))
      expect(r.events[1]).to eq(Date.new(2011, 2, 28))
      expect(r.events[2]).to eq(Date.new(2011, 3, 28))

      r = recurrence(:every => :month, :starts => "2012-01-29", :on => 29, :shift => true)
      expect(r.events[0]).to eq(Date.new(2012, 1, 29))
      expect(r.events[1]).to eq(Date.new(2012, 2, 29))
      expect(r.events[2]).to eq(Date.new(2012, 3, 29))
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
