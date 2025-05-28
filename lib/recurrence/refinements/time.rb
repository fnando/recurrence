# frozen_string_literal: true

class Recurrence_
  module Refinements
    COMMON_YEAR_DAYS_IN_MONTH = [
      nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ].freeze

    refine Time.singleton_class do
      def days_in_month(month, year)
        if month == 2 && ::Date.gregorian_leap?(year)
          29
        else
          COMMON_YEAR_DAYS_IN_MONTH[month]
        end
      end
    end
  end
end
