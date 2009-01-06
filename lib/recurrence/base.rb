class Recurrence
  FREQUENCY = %w(day week month year)
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
    raise ArgumentError, 'invalid :every option' unless FREQUENCY.include?(options[:every].to_s)
    
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
      when :day then
        @event = Recurrence::Event.new(:day, @options)
      when :week then
        raise ArgumentError, 'invalid day' if !DAYS.include?(@options[:on].to_s) && !(0..6).include?(@options[:on])
        @options.merge!(:on => DAYS.index(@options[:on].to_s)) if DAYS.include?(@options[:on].to_s)
        @event = Recurrence::Event.new(:week, @options)
      when :month then
        raise ArgumentError, 'invalid day' unless (1..31).include?(@options[:on])
        options.merge!(:interval => INTERVALS[options[:interval]]) if options[:interval].is_a?(Symbol)
        @event = Recurrence::Event.new(:month, @options)
      when :year then
        raise ArgumentError, 'invalid month' if !(1..12).include?(@options[:on].first) && !MONTHS.keys.include?(@options[:on].first)
        raise ArgumentError, 'invalid day' unless (1..31).include?(@options[:on].last)
        @options.merge!(:on => [MONTHS[@options[:on].first.to_s], @options.last]) unless @options[:on].first.kind_of?(Numeric)
        @event = Recurrence::Event.new(:year, @options)
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
    options[:until] = Date.parse(options[:until]) if options[:until].is_a?(String)
    
    reset! if options[:starts] || options[:until]
    
    @events ||= begin
      _events = []
      
      loop do
        date = @event.next!

        break if date.nil?

        if options[:starts] && options[:until] && date >= options[:starts] && date <= options[:until]
          _events << date
        elsif options[:starts] && options[:until].nil? && date >= options[:starts]
          _events << date
        elsif options[:until] && options[:starts].nil? && date <= options[:until]
          _events << date
        elsif options[:starts].nil? && options[:until].nil?
          _events << date
        end
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
  
  private
    def initialize_dates(options)
      [:starts, :until].each do |name|
        options[name] = Date.parse(options[name]) if options[name].is_a?(String)
      end
      
      options[:starts] ||= Date.today
      options[:until] ||= Date.parse('2037-12-31')
      
      options
    end
end