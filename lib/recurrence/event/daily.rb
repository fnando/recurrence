class Recurrence::Event::Daily < Recurrence::Event

  protected
    def next_in_recurrence
      date  = @date.to_date
      date += @options[:interval] if initialized?
      date
    end

end
