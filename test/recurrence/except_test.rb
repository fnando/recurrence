# frozen_string_literal: true

require "test_helper"

class ExceptTest < Minitest::Test
  using Recurrence::Refinements

  test "accepts only valid date strings or Dates" do
    assert_raises(ArgumentError) { recurrence(except: :symbol) }
    assert_raises(ArgumentError) { recurrence(except: "invalid") }
  end

  test "skips day specified in except" do
    r = recurrence(every: :day, except: Date.tomorrow, until: advance_days(2))

    assert_includes r, Date.today
    refute_includes r, Date.tomorrow
    assert_includes r, Date.tomorrow + 1
  end

  test "skips multiple days specified in except" do
    r = recurrence(every: :day, except: [Date.tomorrow, "2012-02-29"])

    assert_includes r, Date.today
    refute_includes r, Date.tomorrow
    refute_includes r, "2012-02-29"
  end
end
