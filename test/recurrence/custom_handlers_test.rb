# frozen_string_literal: true

require "test_helper"

class CustomHandlersTest < Minitest::Test
  let(:exception_handler) { proc { raise "HANDLED" } }
  let(:shift_handler) do
    proc {|day, month, year|
      day += 1 if month.even?
      Date.new(year, month, day)
    }
  end

  test "offsets every other month day" do
    r = recurrence(every: :month, on: 1, starts: "2011-01-01",
                   handler: shift_handler)

    assert_equal Date.new(2011, 1, 1), r.events[0]
    assert_equal Date.new(2011, 2, 2), r.events[1]
    assert_equal Date.new(2011, 3, 1), r.events[2]
    assert_equal Date.new(2011, 4, 2), r.events[3]
  end

  test "raises an exception from the handler" do
    exception = assert_raises(RuntimeError) do
      recurrence(every: :day, handler: exception_handler)
    end

    assert_equal "HANDLED", exception.message
  end
end
