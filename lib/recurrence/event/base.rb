# frozen_string_literal: true

class Recurrence_
  module Event # :nodoc: all
    class Base
      ORDINALS = %w[first second third fourth fifth].freeze
      WEEKDAYS = {
        "sun" => 0, "sunday"    => 0,
        "mon" => 1, "monday"    => 1,
        "tue" => 2, "tuesday"   => 2,
        "wed" => 3, "wednesday" => 3,
        "thu" => 4, "thursday"  => 4,
        "fri" => 5, "friday"    => 5,
        "sat" => 6, "saturday"  => 6
      }.freeze

      attr_accessor :start_date

      def initialize(options = {})
        @options    = options
        @date       = options[:starts]
        @finished   = false

        validate
        if @options[:interval] <= 0
          raise ArgumentError,
                "interval should be greater than zero"
        end
        if !@options[:repeat].nil? && @options[:repeat] <= 0
          raise ArgumentError,
                "repeat should be greater than zero"
        end

        prepare!
      end

      def next!
        return nil if finished?
        return @date = @start_date if @start_date && @date.nil?

        @date = next_in_recurrence

        @finished = true if @options[:through] && @date >= @options[:through]
        if @date > @options[:until]
          @finished = true
          @date = nil
        end
        shift_to @date if @date && @options[:shift]
        @date
      end

      def next
        return nil if finished?

        @date || @start_date
      end

      def reset!
        @date = nil
        @finished = false
      end

      def finished?
        @finished
      end

      private def initialized?
        !!@start_date
      end

      private def prepare!
        @start_date = next!
        @date       = nil
      end

      private def validate
        # Inject custom validations
      end

      # Common validation for inherited classes.
      #
      private def valid_month_day?(day)
        raise ArgumentError, "invalid day #{day}" unless (1..31).cover?(day)
      end

      # Check if the given key has a valid weekday (0 upto 6) or a valid weekday
      # name (defined in the DAYS constant). If a weekday name (String) is
      # given, convert it to a weekday (Integer).
      #
      private def valid_weekday_or_weekday_name?(value)
        if value.is_a?(Numeric)
          unless (0..6).cover?(value)
            raise ArgumentError,
                  "invalid day #{value}"
          end

          value
        else
          weekday = WEEKDAYS[value.to_s]
          raise ArgumentError, "invalid weekday #{value}" unless weekday

          weekday
        end
      end

      private def shift_to(date)
        # no-op
      end
    end
  end
end
