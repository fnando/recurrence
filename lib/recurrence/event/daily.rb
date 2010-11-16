module SimplesIdeias
  class Recurrence
    module Event
      class Daily < Base # :nodoc: all
        protected
        def next_in_recurrence
          date  = @date.to_date
          date += @options[:interval] if initialized?
          date
        end
      end
    end
  end
end
