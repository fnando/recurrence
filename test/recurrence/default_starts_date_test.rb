# frozen_string_literal: true

require "test_helper"

class DefaultStartsDateTest < Minitest::Test
  test "returns Date.current by default" do
    assert_equal Date.current, Recurrence.default_starts_date
  end

  test "requires only strings and procs" do
    assert_raises(ArgumentError) do
      Recurrence.default_starts_date = Date.tomorrow
    end
  end

  test "applies assigned callable" do
    Recurrence.default_starts_date = -> { Date.tomorrow }

    assert_equal Date.tomorrow, Recurrence.default_starts_date

    r = Recurrence.new(every: :day, until: 3.days.from_now.to_date)

    assert_equal Date.tomorrow, r.events.first
  end
end
