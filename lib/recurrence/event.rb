class Recurrence::Event
  def initialize(every, options={})
    @every = every
    @options = options
    reset!
  end
  
  def find_next
    case @every
      when :day
        if @options.key?(:interval)
          date = @date + @options[:interval].days
        else
          date = @date.next.to_date
        end
      when :week
        if @options[:interval]
          date = @date + @options[:interval].weeks
        else
          date = @date.next
        end
        
        date = date.next until @options[:on] == date.wday
      when :month
        date = @date.beginning_of_month + @options[:interval].months
        day = [@options[:on], Time.days_in_month(date.month, date.year)].min
        date = Date.new(date.year, date.month, day)
      when :year
        day = [Time.days_in_month(@options[:on].first, @date.year), @options[:on].last].min
        date = Date.new(@date.year, @options[:on].first, day)
        date = (date + (@options[:interval] || 1).years).to_date unless date < @date
    end
    
    date = nil unless date && date.to_date <= @options[:until].to_date
    date
  end
  
  def reset!
    @date = @options[:starts]
  end
  
  def find_next!
    @date = find_next
  end
end