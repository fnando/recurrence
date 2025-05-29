# frozen_string_literal: true

require "test_helper"

class Issue36Test < Minitest::Test
  test "returns correct interval" do
    starts = Time.parse("Tue, 19 Apr 2016 10:00:00 BST +01:00")
    r = Recurrence.new(every: :month, on: 19, starts:, repeat: 3)

    assert_equal \
      [Date.new(2016, 4, 19), Date.new(2016, 5, 19), Date.new(2016, 6, 19)],
      r.events
  end
end
