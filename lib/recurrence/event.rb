class Recurrence::Event
  attr_accessor :date, :start_date, :options, :every
  
  def initialize(every, options={})
    @every   = every
    @options = options
    @current = nil
    @date    = options[:starts]
    prepare!
  end
  
  def prepare!
    self.next!
    @start_date = @date
  end
  
  def next?
    !!@next
  end
  
  def next!
    # just continue if date object is null or 
    # hasn't been initialized yet
    return nil unless @date || !inited?
    
    # return the date if is the first interaction after
    # initializing object
    if inited? && !next?
      @next = true
      return @date
    end
    
    case @every
      when :day
        @date = next_day
      when :week
        @date = next_week
      when :month
        @date = next_month
      when :year
        @date = next_year
    end
    
    # if limit date has been reached just set the date 
    # object to nil
    @date = nil unless @date.to_date <= @options[:until].to_date
    
    @date
  end
  
  def next
    @date
  end
  
  def reset!
    @date = @start_date
  end
  
  private
    def inited?
      !!@start_date
    end
  
    def next_day
      date = @date
      date = date + @options[:interval].days if inited? || @options[:interval] > 1
      
      date.to_date
    end
    
    def next_week
      date = @date
      
      if inited?
        date = date + @options[:interval].weeks
      elsif date.wday != @options[:on]
        date = date.next until @options[:on] == date.wday && date > @options[:starts]
        date = date + (@options[:interval] - 1).weeks
      end
      
      date.to_date
    end
    
    def next_month
      date = @date
      
      if inited?
        date = advance_to_month(date)
      else
        day = [options[:on], Time.days_in_month(date.month, date.year)].min
        date = Date.new(date.year, date.month, day)
        date = advance_to_month(date) if @date.day > day
      end

      date.to_date
    end
    
    def advance_to_month(date)
      date = date.beginning_of_month + @options[:interval].months
      day = [options[:on], Time.days_in_month(date.month, date.year)].min
      
      if date.day != day && date.day < day
        date = date.to_date.next until date.day == day
      end
      
      date
    end
    
    def next_year
      date = @date
      
      if inited?
        date = advance_to_year(date)
      else
        day = [options[:on].last, Time.days_in_month(options[:on].first, date.year)].min
        date = Date.new(date.year, options[:on].first, day)
        date = advance_to_year(date) if @date.month > date.month || @options[:on].last < @date.day
      end
      
      date.to_date
    end
    
    def advance_to_year(date)
      date = date.beginning_of_month + @options[:interval].years
      day = [Time.days_in_month(@options[:on].first, date.year), @options[:on].last].min
      year = date.year
    
      date = Date.new(year, @options[:on].first, day)
    end
end
