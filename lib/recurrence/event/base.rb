module SimplesIdeias
  class Recurrence
    module Event # :nodoc: all
      class Base
        ORDINALS = %w(first second third fourth fifth)
        WEEKDAYS = {
          "sun" => 0, "sunday"    => 0,
          "mon" => 1, "monday"    => 1,
          "tue" => 2, "tuesday"   => 2,
          "wed" => 3, "wednesday" => 3,
          "thu" => 4, "thursday"  => 4,
          "fri" => 5, "friday"    => 5,
          "sat" => 6, "saturday"  => 6
        }

        attr_accessor :start_date

        def initialize(options = {})
          every, options = nil, every if every.kind_of?(Hash)

          @options    = options
          @date       = options[:starts]
          @finished   = false

          validate
          raise ArgumentError, "interval should be greater than zero" if @options[:interval] <= 0
          raise ArgumentError, "repeat should be greater than zero" if !@options[:repeat].nil? && @options[:repeat] <= 0

          prepare!
        end

        def next!
          return nil if finished?
          return @date = @start_date if @start_date && @date.nil?

          @date = next_in_recurrence

          @finished = true if @options[:through] && @date >= @options[:through]
          @finished, @date = true, nil if @date > @options[:until]
          shift_to @date if @date && @options[:shift]
          @date
        end

        def next
          return nil if finished?
          @date || @start_date
        end

        def reset!
          @date = nil
        end

        def finished?
          @finished
        end

        private

        def initialized?
          !!@start_date
        end

        def prepare!
          @start_date = next!
          @date       = nil
        end

        def validate
          # Inject custom validations
        end

        # Common validation for inherited classes.
        #
        def valid_month_day?(day)
          raise ArgumentError, "invalid day #{day}" unless (1..31).include?(day)
        end

        # Check if the given key has a valid weekday (0 upto 6) or a valid weekday
        # name (defined in the DAYS constant). If a weekday name (String) is given,
        # convert it to a weekday (Integer).
        #
        def valid_weekday_or_weekday_name?(value)
          if value.kind_of?(Numeric)
            raise ArgumentError, "invalid day #{value}" unless (0..6).include?(value)
            value
          else
            weekday = WEEKDAYS[value.to_s]
            raise ArgumentError, "invalid weekday #{value}" unless weekday
            weekday
          end
        end

        def shift_to(date)
          # no-op
        end
      end
    end
  end
end
