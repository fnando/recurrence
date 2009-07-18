class Recurrence::Event
  attr_accessor :date, :start_date, :options, :every
  
  def initialize(every, options={})
    @every   = every
    @options = options
    @current = nil
    @date    = options[:starts]
    prepare!
    @options[:on].sort! if @every == :week
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
    
    @date = case @every
      when :day
        next_day
      when :week
        next_week
      when :month
        if @options[:weekday]
          next_month_by_weekday
        else
          next_month_by_monthday
        end
      when :year
        next_year
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
      date  = @date.to_date
      date += @options[:interval] if inited?
      date
    end

    def next_week
      return @date if !inited? && @options[:on].include?(@date.wday)

      if next_day = @options[:on].find { |day| day > @date.wday }
        to_add = next_day - @date.wday
      else 
        to_add = (7 - date.wday)                 # Move to next week
        to_add += (@options[:interval] - 1) * 7  # Add extra intervals
        to_add += @options[:on].first            # Go to first required day
      end

      @date.to_date + to_add
    end

    def next_month_by_weekday
      if inited?
        advance_to_month_by_weekday(@date)
      else
        new_date = advance_to_month_by_weekday(@date, 0)
        new_date = advance_to_month_by_weekday(new_date) if @date > new_date
        new_date
      end
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

      date
    end

    def next_month_by_monthday
      if inited?
        advance_to_month_by_monthday(@date)
      else
        new_date = advance_to_month_by_monthday(@date, 0)
        new_date = advance_to_month_by_monthday(new_date) if @date > new_date
        new_date
      end
    end

    def advance_to_month_by_monthday(date, interval=@options[:interval])
      # Have a raw month from 0 to 11 interval
      raw_month  = date.month + interval - 1

      next_year  = date.year + raw_month / 12
      next_month = (raw_month % 12) + 1 # change back to ruby interval
      next_day   = [ @options[:on], Time.days_in_month(next_month, next_year) ].min

      Date.new(next_year, next_month, next_day)
    end

    def next_year
      if inited?
        advance_to_year(@date)
      else
        new_date = advance_to_year(@date, 0)
        new_date = advance_to_year(new_date) if @date > new_date
        new_date
      end
    end

    def advance_to_year(date, interval=@options[:interval])
      next_year  = date.year + interval
      next_month = @options[:on].first
      next_day   = [ @options[:on].last, Time.days_in_month(next_month, next_year) ].min

      Date.new(next_year, next_month, next_day)
    end
end
