class Recurrence::Event
  def initialize(every, options={})
    @every = every
    @options = options
    @started = false
    reset!
  end
  
  def find_next
    case @every
      when :day
        date = find_next_day
      when :week
        date = find_next_week
      when :month
        date = find_next_month
      when :year
        date = find_next_year
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
  
  private
    def started!
      @started = true
    end
    
    def started?
      @started == true
    end
  
    def find_next_day
      if !started?
        started!
        date = @date
      else
        date = @date + @options[:interval].days
      end
      
      date.to_date
    end
    
    def find_next_week
      if !started?
        started!
        date = @date
        
        unless date.wday == @options[:on]
          date = date.next until @options[:on] == date.wday
        end
      else @options[:interval]
        date = @date + @options[:interval].weeks
      end
      
      date.to_date
    end
    
    def find_next_month
      if !started?
        started!
        date = @date
      else
        date = @date.beginning_of_month + @options[:interval].months
      end
      
      day = [@options[:on], Time.days_in_month(date.month, date.year)].min
      date = Date.new(date.year, date.month, day)
      date.to_date
    end
    
    def find_next_year
      if !started?
        started!
        date = @date
      else
        date = @date.beginning_of_month + @options[:interval].years
      end
      
      day = [Time.days_in_month(@options[:on].first, date.year), @options[:on].last].min
      year = date.year
      
      year += 1 if @options[:on].first < date.month
      
      Date.new(year, @options[:on].first, day)
    end
end