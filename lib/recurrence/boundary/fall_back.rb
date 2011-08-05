module SimplesIdeias
  class Recurrence
    module Boundary # :nodoc: all
      ##
      # If the given date is invalid - beyond the end of the month - then this
      # will move the day back to the last day of the given month.
      #
      # Examples
      #
      #   FallBack.call(1, 1, 2011)
      #   # => January 1, 2011
      #
      #   FallBack.call(31, 2, 2011)
      #   # => February 28, 2011
      #
      module FallBack
        def self.call(day, month, year)
          Date.new(year, month, [day, Time.days_in_month(month, year)].min)
        end
      end
    end
  end
end
