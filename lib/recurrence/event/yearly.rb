class Recurrence_
  module Event
    class Yearly < Base # :nodoc: all
      MONTHS = {
        "jan" => 1, "january" => 1,
        "feb" => 2, "february" => 2,
        "mar" => 3, "march" => 3,
        "apr" => 4, "april" => 4,
        "may" => 5,
        "jun" => 6, "june" => 6,
        "jul" => 7, "july" => 7,
        "aug" => 8, "august" => 8,
        "sep" => 9, "september" => 9,
        "oct" => 10, "october" => 10,
        "nov" => 11, "november" => 11,
        "dec" => 12, "december" => 12
      }

      private

      def validate
        valid_month_day?(@options[:on].last)

        if @options[:on].first.kind_of?(Numeric)
          valid_month?(@options[:on].first)
        else
          valid_month_name?(@options[:on].first)
          @options[:on] = [MONTHS[@options[:on].first.to_s], @options[:on].last]
        end
      end

      def next_in_recurrence
        if initialized?
          advance_to_year(@date)
        else
          new_date = advance_to_year(@date, 0)
          new_date = advance_to_year(new_date) if @date > new_date
          @options[:handler].call(new_date.day, new_date.month, new_date.year)
        end
      end

      def advance_to_year(date, interval=@options[:interval])
        next_year  = date.year + interval
        next_month = @options[:on].first

        @options[:handler].call(@options[:on].last, next_month, next_year)
      end

      def shift_to(date)
        @options[:on] = [date.month, date.day]
      end

      private

      def valid_month?(month)
        raise ArgumentError, "invalid month #{month}" unless (1..12).include?(month)
      end

      def valid_month_name?(month)
        raise ArgumentError, "invalid month #{month}" unless MONTHS.keys.include?(month.to_s)
      end
    end
  end
end
