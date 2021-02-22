# frozen_string_literal: true

require "test_helper"

class RecurrenceTest < Minitest::Test
  test "returns the first available date based on initialization" do
    r = recurrence(every: :year, on: [2, 31], starts: "2008-01-01")

    assert_equal "2008-02-29", r.next!.to_s
    assert_equal "2009-02-28", r.next!.to_s
    assert_equal "2010-02-28", r.next!.to_s
    assert_equal "2011-02-28", r.next!.to_s
    assert_equal "2012-02-29", r.next!.to_s
  end

  test "resets to the first available date" do
    r = recurrence(every: :year, on: [2, 31], starts: "2008-01-01")

    assert_equal "2008-02-29", r.next!.to_s
    assert_equal "2009-02-28", r.next!.to_s

    r.reset!

    assert_equal "2008-02-29", r.next.to_s
  end

  test "returns passed-in options" do
    r = recurrence(every: :day)
    options = {every: :day}
    assert_equal options, r.options
  end

  test "returns next date" do
    r = recurrence(every: :day)

    assert_equal Date.current.to_s, r.next.to_s
    assert_equal Date.current.to_s, r.next.to_s
  end

  test "returns next date and advance internal state" do
    r = recurrence(every: :day)

    assert_equal Date.current.to_s, r.next!.to_s
    assert_equal 1.day.from_now.to_date.to_s, r.next!.to_s
    assert_equal 2.days.from_now.to_date.to_s, r.next!.to_s
    assert_equal 3.days.from_now.to_date.to_s, r.next!.to_s
  end

  test "requires :every option" do
    assert_raises(ArgumentError) { recurrence({}) }
  end

  test "requires valid :every option" do
    assert_raises(ArgumentError) { recurrence(every: "invalid") }
  end

  test "requires :interval to be greater than zero when provided" do
    assert_raises(ArgumentError) { recurrence(every: :day, interval: 0) }
  end

  test "requires :repeat to be greater than zero when provided" do
    assert_raises(ArgumentError) { recurrence(every: :day, repeat: 0) }
  end

  test "returns an enumerator when Recurrence#each is called without a block" do
    assert_instance_of Enumerator, recurrence(every: :day).each
  end

  test "returns an enumerator when Recurrence#each! is called with no block" do
    assert_instance_of Enumerator, recurrence(every: :day).each!
  end

  Recurrence::Event::Monthly::INTERVALS.each do |(interval)|
    test "accepts :interval symbol for monthly recurrence (#{interval})" do
      recurrence(every: :month, on: 10, interval: interval)
    end
  end

  Recurrence::Event::Yearly::MONTHS.each do |month_name, _month_number|
    test "accepts month as symbol for yearly recurrence (#{month_name})" do
      recurrence(every: :year, on: [month_name, 10])
    end
  end

  test "requires month to be a valid symbol for yearly recurrence" do
    assert_raises(ArgumentError) do
      recurrence(every: :year, on: [:invalid, 10])
    end
  end

  test "requires :interval to be a valid symbol for monthly recurrence" do
    assert_raises(ArgumentError) do
      recurrence(every: :month, on: 10, interval: :invalid)
    end
  end

  test "resets even when the event iterator has finished" do
    r = recurrence(every: :month, on: 1, starts: "2008-01-01",
                   until: "2008-01-01")

    assert_equal "2008-01-01", r.next!.to_s
    assert_nil r.next!

    r.reset!

    assert_equal "2008-01-01", r.next!.to_s
  end
end
