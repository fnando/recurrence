# frozen_string_literal: true

require "test_helper"

class MonthlyRecurringDayTest < Minitest::Test
  using Recurrence::Refinements

  test "recurs until limit date" do
    r = Recurrence.monthly(on: 31)

    assert_equal Date.parse("2037-12-31"), r.events[-1]
  end

  test "repeats until 8 months from now" do
    date = advance_months(8)
    r = recurrence(every: :month, on: date.day, until: date.to_date)

    assert_equal date.to_date, r.events[-1]
  end

  test "repeats through 8 months from now" do
    date = advance_months(8)
    r = recurrence(every: :month, on: date.day, through: date.to_date)

    assert_equal date.to_date, r.events[-1]
  end

  test "starts 9 months ago" do
    date = Date.today << 9

    r = recurrence(every: :month, on: date.day, starts: date.to_date)

    assert_equal date.to_date, r.events[0]
  end

  test "starts at 2008-06-07 and repeat until 2008-11-07" do
    starts = Date.parse("2008-06-07")
    ends = Date.parse("2008-11-07")

    r = recurrence(
      every: :month,
      on: starts.day,
      starts: starts,
      until: ends
    )

    assert_equal "2008-06-07", r.events[0].to_s
    assert_equal "2008-11-07", r.events[-1].to_s
  end

  test "starts at 2008-06-07 and repeat through 2008-11-07" do
    starts = Date.parse("2008-06-07")
    ends = Date.parse("2008-11-07")

    r = recurrence(
      every: :month,
      on: starts.day,
      starts: starts,
      through: ends
    )

    assert_equal "2008-06-07", r.events[0].to_s
    assert_equal "2008-11-07", r.events[-1].to_s
  end

  test "runs until next available 27th" do
    starts = Date.parse("2008-09-28")

    r = recurrence(
      every: :month,
      on: 27,
      starts: starts,
      until: "2009-01-01"
    )

    assert_equal "2008-10-27", r.events[0].to_s
  end

  test "runs through final available 27th" do
    starts = Date.parse("2008-09-28")

    r = recurrence(
      every: :month,
      on: 27,
      starts: starts,
      through: "2009-01-01"
    )

    assert_equal "2009-01-27", r.events[-1].to_s
  end

  test "uses interval" do
    starts = Date.parse("2008-01-31")
    r = recurrence(
      every: :month,
      on: 31,
      interval: 2,
      starts: starts,
      until: "2010-01-01"
    )

    assert_equal "2008-01-31", r.events[0].to_s
    assert_equal "2008-03-31", r.events[1].to_s
    assert_equal "2008-05-31", r.events[2].to_s
    assert_equal "2008-07-31", r.events[3].to_s
    assert_equal "2008-09-30", r.events[4].to_s
    assert_equal "2008-11-30", r.events[5].to_s
    assert_equal "2009-01-31", r.events[6].to_s

    starts = Date.parse("2008-01-31")
    r = recurrence(
      every: :month,
      on: 29,
      interval: 3,
      starts: starts,
      until: "2010-01-01"
    )

    assert_equal "2008-04-29", r.events[0].to_s
    assert_equal "2008-07-29", r.events[1].to_s
    assert_equal "2008-10-29", r.events[2].to_s
    assert_equal "2009-01-29", r.events[3].to_s
    assert_equal "2009-04-29", r.events[4].to_s
    assert_equal "2009-07-29", r.events[5].to_s

    starts = Date.parse("2008-02-29")
    r = recurrence(
      every: :month,
      on: 31,
      interval: 4,
      starts: starts,
      until: "2010-01-01"
    )

    assert_equal "2008-02-29", r.events[0].to_s
    assert_equal "2008-06-30", r.events[1].to_s
    assert_equal "2008-10-31", r.events[2].to_s
    assert_equal "2009-02-28", r.events[3].to_s
  end

  test "uses repeat" do
    starts = Date.parse("2008-01-31")
    r = recurrence(
      every: :month,
      on: 31,
      starts: starts,
      until: "2010-01-01",
      repeat: 5
    )

    assert_equal 5, r.events.size
  end

  test "uses except" do
    r = recurrence(every: :month,
                   on: Date.today.day,
                   except: advance_months(7),
                   until: advance_months(9))

    assert_includes r.events, advance_months(6)
    refute_includes r.events, advance_months(7)
    assert_includes r.events, advance_months(8)
    assert_includes r.events, advance_months(9)
  end
end
