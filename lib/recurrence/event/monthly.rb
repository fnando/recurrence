# frozen_string_literal: true

class Recurrence_
  module Event
    class Monthly < Base # :nodoc: all
      INTERVALS = {
        monthly: 1,
        bimonthly: 2,
        quarterly: 3,
        semesterly: 6
      }.freeze

      private def validate
        if @options.key?(:weekday)
          # Allow :on => :last, :weekday => :thursday contruction.
          if @options[:on].to_s == "last"
            @options[:on] = 5
          elsif @options[:on].is_a?(Numeric)
            validate_week(@options[:on])
          else
            validate_ordinal(@options[:on])
            @options[:on] = ORDINALS.index(@options[:on].to_s) + 1
          end

          @options[:weekday] = expand_weekday!(@options[:weekday])
        else
          validate_month_day(@options[:on])
        end

        return unless @options[:interval].is_a?(Symbol)

        validate_interval(@options[:interval])
        @options[:interval] = INTERVALS[@options[:interval]]
      end

      private def next_in_recurrence
        return next_month if respond_to?(:next_month)

        type = @options.key?(:weekday) ? :weekday : :monthday

        singleton_class.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          # private def next_month
          #   if initialized?
          #     advance_to_month_by_weekday(@date)
          #   else
          #     new_date = advance_to_month_by_weekday(@date, 0)
          #     new_date = advance_to_month_by_weekday(new_date) if @date > new_date
          #     new_date
          #   end
          # end
          private def next_month
            if initialized?
              advance_to_month_by_#{type}(@date)
            else
              new_date = advance_to_month_by_#{type}(@date, 0)
              new_date = advance_to_month_by_#{type}(new_date) if @date > new_date
              new_date
            end
          end
        METHOD

        next_month
      end

      private def advance_to_month_by_monthday(
        date,
        interval = @options[:interval]
      )
        # Have a raw month from 0 to 11 interval
        raw_month  = date.month + interval - 1

        next_year  = date.year + raw_month.div(12)
        next_month = (raw_month % 12) + 1 # change back to ruby interval

        @options[:handler].call(@options[:on], next_month, next_year)
      end

      private def advance_to_month_by_weekday(
        date,
        interval = @options[:interval]
      )
        raw_month  = date.month + interval - 1
        next_year  = date.year + raw_month.div(12)
        next_month = (raw_month % 12) + 1 # change back to ruby interval
        date       = Date.new(next_year, next_month, 1)

        weekday = @options[:weekday]
        month = date.month

        # Adjust week day
        to_add  = weekday - date.wday
        to_add += 7 if to_add.negative?
        to_add += (@options[:on] - 1) * 7
        date   += to_add

        # Go to the previous month if we lost it
        if date.month != month
          weeks = (date.day - 1).div(7) + 1
          date -= weeks * 7
        end

        @options[:handler].call(date.day, date.month, date.year)
      end

      private def shift_to(date)
        @options[:on] = date.day unless @options[:weekday]
      end

      private def validate_ordinal(ordinal)
        return if ORDINALS.include?(ordinal.to_s)

        raise ArgumentError, "invalid ordinal #{ordinal}"
      end

      private def validate_interval(interval)
        return if INTERVALS.key?(interval)

        raise ArgumentError, "invalid ordinal #{interval}"
      end

      private def validate_week(week)
        raise ArgumentError, "invalid week #{week}" unless (1..5).cover?(week)
      end
    end
  end
end
