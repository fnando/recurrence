module SimplesIdeias
  class Recurrence
    module Event
      class Monthly < Base # :nodoc: all
        INTERVALS = {
          :monthly    => 1,
          :bimonthly  => 2,
          :quarterly  => 3,
          :semesterly => 6
        }

        protected
        def validate
          if @options.key?(:weekday)

            # Allow :on => :last, :weekday => :thursday contruction.
            if @options[:on].to_s == "last"
              @options[:on] = 5
            elsif @options[:on].kind_of?(Numeric)
              valid_week?(@options[:on])
            else
              valid_cardinal?(@options[:on])
              @options[:on] = CARDINALS.index(@options[:on].to_s) + 1
            end

            @options[:weekday] = valid_weekday_or_weekday_name?(@options[:weekday])
          else
            valid_month_day?(@options[:on])
          end

          if @options[:interval].kind_of?(Symbol)
            valid_interval?(@options[:interval])
            @options[:interval] = INTERVALS[@options[:interval]]
          end
        end

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

          @options[:handler].call(@options[:on], next_month, next_year)
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

          @options[:handler].call(date.day, date.month, date.year)
        end

        private
        def valid_cardinal?(cardinal)
          raise ArgumentError, "invalid cardinal #{cardinal}" unless CARDINALS.include?(cardinal.to_s)
        end

        def valid_interval?(interval)
          raise ArgumentError, "invalid cardinal #{interval}" unless INTERVALS.key?(interval)
        end

        def valid_week?(week)
          raise ArgumentError, "invalid week #{week}" unless (1..5).include?(week)
        end
      end
    end
  end
end
