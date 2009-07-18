class Recurrence
  FREQUENCY = %w(day week month year)
  CARDINALS = %w(first second third fourth fifth)
  DAYS = %w(sunday monday tuesday wednesday thursday friday saturday)

  MONTHS = {
    "jan" => 1, "january" => 1,
    "feb" => 2, "february" => 2,
    "mar" => 3, "march" => 3,
    "apr" => 4, "april" => 4,
    "may" => 5,
    "jun" => 6, "june" => 6,
    "jul" => 7, "july" => 7,
    "aug" => 8, "august" => 8,
    "sep" => 9, "september" => 9,
    "oct" => 10, "october" => 10,
    "nov" => 11, "november" => 11,
    "dec" => 12, "december" => 12
  }
  
  INTERVALS = {
    :monthly => 1,
    :bimonthly => 2,
    :quarterly => 3,
    :semesterly => 6
  }
  
  attr_reader :event
  
  def initialize(options)
    raise ArgumentError, ':every option is required' unless options.key?(:every)
    raise ArgumentError, 'invalid :every option'     unless FREQUENCY.include?(options[:every].to_s)
    
    if options.key?(:interval)
      if options[:every].to_sym == :month && options[:interval].is_a?(Symbol) && !INTERVALS.key?(options[:interval])
        raise ArgumentError, 'interval symbol is not valid'
      elsif options[:interval].to_i == 0
        raise ArgumentError, 'interval should be greater than zero'
      end
    end
    
    @options = initialize_dates(options)
    @options[:interval] ||= 1
    
    case @options[:every].to_sym
      when :day
        @event = Recurrence::Event::Daily.new(@options)
      when :week
        @options[:on] = Array.wrap(@options[:on]).inject([]) do |days, value|
          days << valid_weekday_or_weekday_name?(value)
        end

        @event = Recurrence::Event::Weekly.new(@options)
      when :month
        if @options.key?(:weekday)

          # Allow :on => :last, :weekday => :thursday contruction.
          if @options[:on].to_s == 'last'
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

        if @options[:interval].is_a?(Symbol)
          valid_interval?(@options[:interval])
          @options[:interval] = INTERVALS[@options[:interval]]
        end

        @event = Recurrence::Event::Monthly.new(@options)
      when :year
        valid_month_day?(@options[:on].last)

        if @options[:on].first.kind_of?(Numeric)
          valid_month?(@options[:on].first)
        else
          valid_month_name?(@options[:on].first)
          @options[:on] = [ MONTHS[@options[:on].first.to_s], @options.last ]
        end

        @event = Recurrence::Event::Yearly.new(@options)
    end
  end
  
  def reset!
    @event.reset!
    @events = nil
  end
  
  def include?(required_date)
    required_date = Date.parse(required_date) if required_date.is_a?(String)
    
    if required_date < @options[:starts] || required_date > @options[:until]
      false
    else
      each do |date|
        return true if date == required_date
      end
    end
    
    return false
  end
  
  def next
    @event.next
  end
  
  def next!
    @event.next!
  end
  
  def events(options={})
    options[:starts] = Date.parse(options[:starts]) if options[:starts].is_a?(String)
    options[:until]  = Date.parse(options[:until])  if options[:until].is_a?(String)
    
    reset! if options[:starts] || options[:until]
    
    @events ||= begin
      _events = []
      
      loop do
        date = @event.next!

        break if date.nil?

        valid_start = options[:starts].nil? || date >= options[:starts]
        valid_until = options[:until].nil?  || date <= options[:until]
        _events << date if valid_start && valid_until
        
        break if options[:until] && options[:until] <= date
      end
      
      _events
    end
  end
  
  def events!(options={})
    reset!
    events(options)
  end
  
  def each!(&block)
    reset!
    each(&block)
  end
  
  def each(&block)
    events.each do |item|
      yield item
    end
  end

  # Recurrence.type shortcuts
  #
  def self.daily(options={})
    options[:every] = :day
    new(options)
  end

  def self.weekly(options)
    options[:every] = :week
    new(options)
  end

  def self.monthly(options)
    options[:every] = :month
    new(options)
  end

  def self.yearly(options)
    options[:every] = :year
    new(options)
  end

  private

    def initialize_dates(options) #:nodoc:
      [:starts, :until].each do |name|
        options[name] = Date.parse(options[name]) if options[name].is_a?(String)
      end

      options[:starts] ||= Date.today
      options[:until] ||= Date.parse('2037-12-31')

      options
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

    def valid_cardinal?(cardinal)
      raise ArgumentError, "invalid cardinal #{cardinal}" unless CARDINALS.include?(cardinal.to_s)
    end

    def valid_interval?(interval)
      raise ArgumentError, "invalid cardinal #{interval}" unless INTERVALS.key?(interval)
    end

    def valid_week?(week) #:nodoc:
      raise ArgumentError, "invalid week #{week}" unless (1..5).include?(week)
    end

    def valid_month?(month) #:nodoc:
      raise ArgumentError, "invalid month #{month}" unless (1..12).include?(month)
    end

    def valid_month_day?(day) #:nodoc:
      raise ArgumentError, "invalid day #{day}" unless (1..31).include?(day)
    end

    def valid_month_name?(month) #:nodoc:
      raise ArgumentError, "invalid month #{month}" unless MONTHS.keys.include?(month.to_s)
    end
end
