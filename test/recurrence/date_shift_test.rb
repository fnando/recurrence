# frozen_string_literal: true

require "test_helper"

class DateShiftTest < Minitest::Test
  test "shifts yearly recurrences around February 29" do
    r = recurrence(every: :year, starts: "2012-02-29", on: [2, 29],
                   shift: true)

    assert_equal Date.new(2012, 2, 29), r.events[0]
    assert_equal Date.new(2013, 2, 28), r.events[1]
    assert_equal Date.new(2014, 2, 28), r.events[2]
    assert_equal Date.new(2015, 2, 28), r.events[3]
    assert_equal Date.new(2016, 2, 28), r.events[4]
  end

  test "shifts monthly recurrences around the 31st" do
    r = recurrence(every: :month, starts: "2011-01-31", on: 31,
                   shift: true)

    assert_equal Date.new(2011, 1, 31), r.events[0]
    assert_equal Date.new(2011, 2, 28), r.events[1]
    assert_equal Date.new(2011, 3, 28), r.events[2]
  end

  test "shifts monthly recurrences around the 30th" do
    r = recurrence(every: :month, starts: "2011-01-30", on: 30,
                   shift: true)

    assert_equal Date.new(2011, 1, 30), r.events[0]
    assert_equal Date.new(2011, 2, 28), r.events[1]
    assert_equal Date.new(2011, 3, 28), r.events[2]
  end

  test "shifts monthly recurrences around the 29th" do
    r = recurrence(every: :month, starts: "2011-01-29", on: 29,
                   shift: true)

    assert_equal Date.new(2011, 1, 29), r.events[0]
    assert_equal Date.new(2011, 2, 28), r.events[1]
    assert_equal Date.new(2011, 3, 28), r.events[2]

    r = recurrence(every: :month, starts: "2012-01-29", on: 29,
                   shift: true)

    assert_equal Date.new(2012, 1, 29), r.events[0]
    assert_equal Date.new(2012, 2, 29), r.events[1]
    assert_equal Date.new(2012, 3, 29), r.events[2]
  end

  test "correctly resets to original day for monthly" do
    r = recurrence(every: :month, starts: "2011-01-31", on: 31,
                   shift: true)

    r.next!
    r.next!

    assert_equal Date.new(2011, 2, 28), r.next

    r.reset!

    assert_equal Date.new(2011, 1, 31), r.next
  end

  test "correctly resets to original month and day for yearly" do
    r = recurrence(every: :year, starts: "2012-02-29", on: [2, 29],
                   shift: true)

    r.next!
    r.next!

    assert_equal Date.new(2013, 2, 28), r.next

    r.reset!

    assert_equal Date.new(2012, 2, 29), r.next
  end

  test "correctly recurrs for weekdays" do
    r = recurrence(every: :month,
                   starts: "2011-01-31",
                   on: "first",
                   weekday: "monday",
                   shift: true)

    assert_equal Date.new(2011, 2, 7), r.events[0]
    assert_equal Date.new(2011, 3, 7), r.events[1]
    assert_equal Date.new(2011, 4, 4), r.events[2]
  end
end
