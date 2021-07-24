class Recurrence_
  module Event
    class Monthly < Base
      module Weekday
        def advance(date, interval=@options[:interval])
          raw_month  = date.month + interval - 1
          next_year  = date.year + raw_month.div(12)
          next_month = (raw_month % 12) + 1 # change back to ruby interval
          date       = Date.new(next_year, next_month, 1)

          weekday, month = @options[:weekday], date.month

          # Adjust week day
          to_add  = weekday - date.wday
          to_add += 7 if to_add < 0
          to_add += (@options[:on] - 1) * 7
          date   += to_add

          # Go to the previous month if we lost it
          if date.month != month
            weeks = (date.day - 1).div(7) + 1
            date -= weeks * 7
          end

          @options[:handler].call(date.day, date.month, date.year)
        end

        def validate_and_prepare!
          # Allow :on => :last, :weekday => :thursday contruction.
          if @options[:on].to_s == "last"
            @options[:on] = 5
          elsif @options[:on].kind_of?(Numeric)
            valid_week?(@options[:on])
          else
            valid_ordinal?(@options[:on])
            @options[:on] = Monthly::ORDINALS.index(@options[:on].to_s) + 1
          end

          @options[:weekday] = valid_weekday_or_weekday_name?(@options[:weekday])

          if @options[:interval].kind_of?(Symbol)
            valid_interval?(@options[:interval])
            @options[:interval] = INTERVALS[@options[:interval]]
          end
        end

        def shift_to(date)
          @options[:on] = date.day
        end
      end
    end
  end
end
