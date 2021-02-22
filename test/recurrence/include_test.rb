# frozen_string_literal: true

require "test_helper"

class IncludeTest < Minitest::Test
  test "includes date (day)" do
    r = recurrence(every: :day, starts: "2008-09-30")
    assert r.include?("2008-09-30")
    assert r.include?("2008-10-01")
  end

  test "includes date (week)" do
    r = recurrence(every: :week, on: :thursday, starts: "2008-09-30")
    refute r.include?("2008-09-30")
    assert r.include?("2008-10-02")

    r = recurrence(every: :week, on: :monday, starts: "2008-09-29")
    assert r.include?("2008-09-29")
    assert r.include?("2008-10-06")
  end

  test "includes date (month)" do
    r = recurrence(every: :month, on: 10, starts: "2008-09-30")
    refute r.include?("2008-09-30")
    assert r.include?("2008-10-10")

    r = recurrence(every: :month, on: 10, starts: "2008-09-10")
    assert r.include?("2008-09-10")
    assert r.include?("2008-10-10")
  end

  test "includes date (year)" do
    r = recurrence(every: :year, on: [6, 28], starts: "2008-09-30")
    refute r.include?("2009-09-30")
    assert r.include?("2009-06-28")

    r = recurrence(every: :year, on: [6, 28], starts: "2008-06-28")
    assert r.include?("2009-06-28")
    assert r.include?("2009-06-28")
  end

  test "doesn't include date when is smaller than starting date (day)" do
    r = recurrence(every: :day, starts: "2008-09-30")
    refute r.include?("2008-09-29")
  end

  test "doesn't include date when is smaller than starting date (week)" do
    r = recurrence(every: :week, on: :friday, starts: "2008-09-30")
    refute r.include?("2008-09-24")
  end

  test "doesn't include date when is smaller than starting date (month)" do
    r = recurrence(every: :month, on: 10, starts: "2008-09-30")
    refute r.include?("2008-09-10")
  end

  test "doesn't include date when is smaller than starting date (year)" do
    r = recurrence(every: :year, on: [6, 28], starts: "2008-09-30")
    refute r.include?("2008-06-28")
  end

  test "doesn't include date when is greater than ending date (day)" do
    r = recurrence(every: :day, until: "2008-09-30")
    refute r.include?("2008-10-01")
  end

  test "doesn't include date when is greater than ending date (week)" do
    r = recurrence(every: :week, on: :friday, until: "2008-09-30")
    refute r.include?("2008-10-03")
  end

  test "doesn't include date when is greater than ending date (year)" do
    r = recurrence(every: :year, on: [6, 28], until: "2008-09-30")
    refute r.include?("2009-06-28")
  end
end
