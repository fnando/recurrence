class Recurrence_
  module Event
    class Monthly < Base
      module Monthday
        def advance(date, interval=@options[:interval])
          if initialized? && @_day_count > @_day_pointer += 1
            @options[:handler].call(
              @options[:on][@_day_pointer],
              date.month,
              date.year
            )
          else
            @_day_pointer = 0

            # Have a raw month from 0 to 11 interval
            raw_month  = date.month + interval - 1

            next_year  = date.year + raw_month.div(12)
            next_month = (raw_month % 12) + 1 # change back to ruby interval

            @options[:handler].call(
              @options[:on][@_day_pointer],
              next_month,
              next_year
            )
          end
        end

        def validate_and_prepare!
          @options[:on] = Array.wrap(@options[:on]).map do |day|
            valid_month_day?(day)
            day
          end.sort

          valid_shift_options?

          if @options[:interval].kind_of?(Symbol)
            valid_interval?(@options[:interval])
            @options[:interval] = INTERVALS[@options[:interval]]
          end

          @_day_pointer = 0
          @_day_count = @options[:on].length
        end

        def valid_shift_options?
          if @options[:shift] && @options[:on].length > 1
            raise ArgumentError, "Invalid options. Unable to use :shift with multiple :on days"
          end
        end

        def shift_to(date)
          @options[:on][0] = date.day
        end
      end
    end
  end
end

