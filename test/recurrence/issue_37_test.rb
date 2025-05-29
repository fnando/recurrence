# frozen_string_literal: true

require "test_helper"

class Issue37Test < Minitest::Test
  def recurrence
    Recurrence.new(
      every: :week,
      on: %i[monday tuesday wednesday thursday],
      starts: "2021-10-01",
      until: "2021-10-10"
    )
  end

  test "events without start_date, end_date" do
    r = recurrence

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events
  end

  test "events with start_date, end_date within actual end_date" do
    r = recurrence

    assert_equal \
      [Date.new(2021, 10, 4), Date.new(2021, 10, 5), Date.new(2021, 10, 6)],
      r.events(
        starts: "2021-10-04",
        until: "2021-10-06"
      )
    assert_equal r.events(
      starts: "2021-10-04",
      until: "2021-10-06"
    ), [Date.new(2021, 10, 4), Date.new(2021, 10, 5), Date.new(2021, 10, 6)]
  end

  test "events with start_date, end_date as actual end_date" do
    r = recurrence

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events(starts: "2021-10-04", until: "2021-10-10")

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events(starts: "2021-10-04", until: "2021-10-10")
  end

  test "events with start_date, end_date as actual end_date (using events!)" do
    r = recurrence

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events!(starts: "2021-10-04", until: "2021-10-10")

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events!(starts: "2021-10-04", until: "2021-10-10")
  end

  test "events with start_date, end_date outside end_date" do
    r = recurrence

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events(starts: "2021-09-30", until: "2021-10-15")

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events(starts: "2021-09-30", until: "2021-10-15")
  end

  test "events with start_date, end_date outside end_date (using events!)" do
    r = recurrence

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events!(starts: "2021-09-30", until: "2021-10-15")

    assert_equal \
      [
        Date.new(2021, 10, 4),
        Date.new(2021, 10, 5),
        Date.new(2021, 10, 6),
        Date.new(2021, 10, 7)
      ],
      r.events!(starts: "2021-09-30", until: "2021-10-15")
  end
end
