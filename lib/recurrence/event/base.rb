module SimplesIdeias
  class Recurrence
    module Event
      class Base
        CARDINALS = %w(first second third fourth fifth)
        DAYS = %w(sunday monday tuesday wednesday thursday friday saturday)

        attr_accessor :start_date

        def initialize(options={})
          every, options = nil, every if every.is_a?(Hash)

          @options    = options
          @date       = options[:starts]
          @finished   = false

          validate
          raise ArgumentError, "interval should be greater than zero" if @options[:interval] <= 0

          prepare!
        end

        def next!
          return nil if finished?
          return @date = @start_date if @start_date && @date.nil?

          @date = next_in_recurrence

          @finished, @date = true, nil if @date > @options[:until]
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
        def valid_month_day?(day) #:nodoc:
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
            raise ArgumentError, "invalid weekday #{value}" unless DAYS.include?(value.to_s)
            DAYS.index(value.to_s)
          end
        end
      end
    end
  end
end
