# frozen_string_literal: true

require "test_helper"

class EventsTest < Minitest::Test
  let(:r) do
    recurrence(every: :day, starts: "2009-01-06", until: "2009-01-15")
  end

  test "returns starting and ending recurrences" do
    assert_equal "2009-01-06", r.events[0].to_s
    assert_equal "2009-01-15", r.events[-1].to_s
  end

  test "returns only events greater than starting date" do
    events = r.events(starts: "2009-01-10")

    assert_equal "2009-01-10", events[0].to_s
  end

  test "returns only events smaller than until date" do
    events = r.events(until: "2009-01-10")

    assert_equal "2009-01-06", events[0].to_s
    assert_equal "2009-01-10", events[-1].to_s
  end

  test "returns only events between starting and until date" do
    events = r.events(starts: "2009-01-12", until: "2009-01-14")

    assert_equal "2009-01-12", events[0].to_s
    assert_equal "2009-01-14", events[-1].to_s
  end

  test "doesn't iterate all dates when using until" do
    events = r.events(starts: "2009-01-06", until: "2009-01-08")

    assert_equal 3, r.events.size
    assert_equal 3, events.size
    assert_equal "2009-01-08", events[-1].to_s
  end

  test "uses name as symbol [issue#3]" do
    recurrence(every: :year, on: [:jan, 31])
  end
end
