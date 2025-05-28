# frozen_string_literal: true

require "test_helper"

class DailyRecurringTest < Minitest::Test
  test "recurs until limit date" do
    r = Recurrence.daily

    assert_equal Date.parse("2037-12-31"), r.events[-1]
  end

  test "repeats until 1 month from now" do
    date = 1.month.from_now
    r = recurrence(every: :day, until: date.to_date)

    assert_equal date.to_date, r.events[-1]
  end

  test "recurs through 1 month from now" do
    date = 1.month.from_now
    r = recurrence(every: :day, through: date.to_date)

    assert_equal date.to_date, r.events[-1]
  end

  test "starts 2 months ago (#{2.months.ago.to_date})" do
    date = 2.months.ago
    r = recurrence(every: :day, starts: date.to_date)

    assert_equal date.to_date, r.events[0]
    assert_equal (date + 1.day).to_date, r.events[1].to_date
    assert_equal (date + 2.day).to_date, r.events[2].to_date
  end

  test "starts at 2008-03-19 and repeat until 2008-04-24" do
    r = recurrence(every: :day, starts: "2008-03-19",
                   until: "2008-04-24")

    assert_equal "2008-03-19", r.events[0].to_s
    assert_equal "2008-03-20", r.events[1].to_s
    assert_equal "2008-04-24", r.events[-1].to_s
  end

  test "starts at 2008-03-19 and repeat through 2008-04-24" do
    r = recurrence(every: :day, starts: "2008-03-19",
                   through: "2008-04-24")

    assert_equal "2008-03-19", r.events[0].to_s
    assert_equal "2008-03-20", r.events[1].to_s
    assert_equal "2008-04-24", r.events[-1].to_s
  end

  test "uses interval" do
    r = recurrence(every: :day, interval: 2, starts: "2008-09-21")

    assert_equal "2008-09-21", r.events[0].to_s
    assert_equal "2008-09-23", r.events[1].to_s
    assert_equal "2008-09-25", r.events[2].to_s
  end

  test "uses repeat" do
    r = recurrence(every: :day, starts: "2008-09-21", repeat: 10)

    assert_equal 10, r.events.size
  end

  test "has a lacking day if the interval does not match the last day" do
    r = recurrence(
      every: :day,
      starts: "2008-03-19",
      until: "2008-04-25",
      interval: 2
    )

    assert_equal "2008-04-24", r.events[-1].to_s
  end

  test "doesn't have a lacking day when interval doesn't match the last day" do
    r = recurrence(
      every: :day,
      starts: "2008-03-19",
      through: "2008-04-25",
      interval: 2
    )

    assert_equal "2008-04-26", r.events[-1].to_s
  end

  test "uses except" do
    r = Recurrence.daily(except: Date.tomorrow)

    refute_includes r.events, Date.tomorrow
    assert_includes r.events, Date.tomorrow + 1.day
  end
end
