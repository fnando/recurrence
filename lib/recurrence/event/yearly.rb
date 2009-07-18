class Recurrence::Event::Yearly < Recurrence::Event

  protected

    def next_in_recurrence
      if initialized?
        advance_to_year(@date)
      else
        new_date = advance_to_year(@date, 0)
        new_date = advance_to_year(new_date) if @date > new_date
        new_date
      end
    end

    def advance_to_year(date, interval=@options[:interval])
      next_year  = date.year + interval
      next_month = @options[:on].first
      next_day   = [ @options[:on].last, Time.days_in_month(next_month, next_year) ].min

      Date.new(next_year, next_month, next_day)
    end

end
