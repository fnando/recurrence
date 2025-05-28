# frozen_string_literal: true

require "test_helper"

class MonthlyRecurringIntervalTest < Minitest::Test
  let(:starts) { Date.parse("2008-09-03") }

  test "uses numeric interval" do
    r = recurrence(every: :month, on: 21, interval: 2,
                   starts: starts)

    assert_equal "2008-09-21", r.events[0].to_s
    assert_equal "2008-11-21", r.events[1].to_s
    assert_equal "2009-01-21", r.events[2].to_s
    assert_equal "2009-03-21", r.events[3].to_s
  end

  test "accepts monthly symbol" do
    r = recurrence(
      every: :month,
      on: 10,
      starts: starts,
      interval: :monthly
    )

    assert_equal "2008-09-10", r.events[0].to_s
    assert_equal "2008-10-10", r.events[1].to_s
  end

  test "accepts bimonthly symbol" do
    r = recurrence(
      every: :month,
      on: 10,
      starts: starts,
      interval: :bimonthly
    )

    assert_equal "2008-09-10", r.events[0].to_s
    assert_equal "2008-11-10", r.events[1].to_s
  end

  test "accepts quarterly symbol" do
    r = recurrence(
      every: :month,
      on: 10,
      starts: starts,
      interval: :quarterly
    )

    assert_equal "2008-09-10", r.events[0].to_s
    assert_equal "2008-12-10", r.events[1].to_s
  end

  test "accepts semesterly symbol" do
    r = recurrence(every: :month, on: 10, starts: starts,
                   interval: :semesterly)

    assert_equal "2008-09-10", r.events[0].to_s
    assert_equal "2009-03-10", r.events[1].to_s
  end
end
