class Recurrence_
  module Event
    class Monthly < Base # :nodoc: all
      INTERVALS = {
        :monthly    => 1,
        :bimonthly  => 2,
        :quarterly  => 3,
        :semesterly => 6
      }

      private

      def validate
        if @options.key?(:weekday)
          extend Weekday
        else
          extend Monthday
        end

        validate_and_prepare!
      end

      def next_in_recurrence
        if initialized?
          advance(@date)
        else
          new_date = advance(@date, 0)
          new_date = advance(new_date) if @date > new_date
          new_date
        end
      end

      private

      def valid_ordinal?(ordinal)
        raise ArgumentError, "invalid ordinal #{ordinal}" unless ORDINALS.include?(ordinal.to_s)
      end

      def valid_interval?(interval)
        raise ArgumentError, "invalid ordinal #{interval}" unless INTERVALS.key?(interval)
      end

      def valid_week?(week)
        raise ArgumentError, "invalid week #{week}" unless (1..5).include?(week)
      end
    end
  end
end
