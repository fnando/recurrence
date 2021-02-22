# frozen_string_literal: true

require "test_helper"

class MonthlyRecurringWeekdayTest < Minitest::Test
  test "recurs until limit date" do
    r = Recurrence.daily(on: 5, weekday: :thursday)
    assert_equal Date.parse("2037-12-31"), r.events[-1]
  end

  test "uses weekday shortcut" do
    r = Recurrence.daily(on: 5, weekday: :thu)
    assert_equal Date.parse("2037-12-31"), r.events[-1]
  end

  test "repeats until 8 months from now" do
    date = 8.months.from_now
    week = (date.day - 1) / 7 + 1
    r = recurrence(
      every: :month,
      on: week,
      weekday: date.wday,
      until: date.to_date
    )
    assert_equal date.to_date, r.events[-1]
  end

  test "repeats through 8 months from now" do
    date = 8.months.from_now
    week = (date.day - 1) / 7 + 1
    r = recurrence(
      every: :month,
      on: week,
      weekday: date.wday,
      through: date.to_date
    )
    assert_equal date.to_date, r.events[-1]
  end

  test "starts 9 months ago" do
    date = 9.months.ago
    week = (date.day - 1) / 7 + 1
    r = recurrence(
      every: :month,
      on: week,
      weekday: date.wday,
      starts: date.to_date
    )
    assert_equal date.to_date, r.events[0]
  end

  test "starts at 2008-06-07 and repeat until 2008-11-01 (first saturday)" do
    starts = Date.parse("2008-06-07")
    ends = Date.parse("2008-11-01")

    r = recurrence(
      every: :month,
      on: :first,
      weekday: :saturday,
      starts: starts,
      until: ends
    )
    assert_equal "2008-06-07", r.events[0].to_s
    assert_equal "2008-11-01", r.events[-1].to_s
  end

  test "starts at 2008-06-29 and repeat until 2008-11-30 (last sunday)" do
    starts = Date.parse("2008-06-29")
    ends = Date.parse("2008-11-30")

    r = recurrence(
      every: :month,
      on: :last,
      weekday: :sunday,
      starts: starts,
      until: ends
    )
    assert_equal "2008-06-29", r.events[0].to_s
    assert_equal "2008-11-30", r.events[-1].to_s
  end

  test "uses interval" do
    starts = Date.parse("2009-01-01")
    r = recurrence(
      every: :month,
      on: :third,
      weekday: :sunday,
      interval: 2,
      starts: starts,
      until: "2010-02-01"
    )
    assert_equal "2009-01-18", r.events[0].to_s
    assert_equal "2009-03-15", r.events[1].to_s
    assert_equal "2009-05-17", r.events[2].to_s
    assert_equal "2009-07-19", r.events[3].to_s
    assert_equal "2009-09-20", r.events[4].to_s
    assert_equal "2009-11-15", r.events[5].to_s
    assert_equal "2010-01-17", r.events[6].to_s
  end

  test "uses repeat" do
    starts = Date.parse("2009-01-01")
    r = recurrence(
      every: :month,
      on: :third,
      weekday: :sunday,
      starts: starts,
      until: "2011-02-01",
      repeat: 5
    )
    assert_equal 5, r.events.size
  end
end
