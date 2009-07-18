class Recurrence::Event::Monthly < Recurrence::Event

  protected

    def next_in_recurrence
      return next_month if self.respond_to?(:next_month)
      type = @options.key?(:weekday) ? :weekday : :monthday

      class_eval <<-METHOD
        def next_month
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

    def advance_to_month_by_monthday(date, interval=@options[:interval])
      # Have a raw month from 0 to 11 interval
      raw_month  = date.month + interval - 1

      next_year  = date.year + raw_month / 12
      next_month = (raw_month % 12) + 1 # change back to ruby interval
      next_day   = [ @options[:on], Time.days_in_month(next_month, next_year) ].min

      Date.new(next_year, next_month, next_day)
    end

    def advance_to_month_by_weekday(date, interval=@options[:interval])
      raw_month  = date.month + interval - 1
      next_year  = date.year + raw_month / 12
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
        weeks = (date.day - 1) / 7 + 1
        date -= weeks * 7
      end

      date
    end

end
