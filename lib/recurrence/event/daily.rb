# frozen_string_literal: true

class Recurrence_
  module Event
    class Daily < Base # :nodoc: all
      private def next_in_recurrence
        date  = @date.to_date
        date += @options[:interval] if initialized?
        @options[:handler].call(date.day, date.month, date.year)
      end
    end
  end
end
