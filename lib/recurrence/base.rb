class Recurrence
  FREQUENCY = %w(day week month year)
  DAYS = %w(sunday monday tuesday wednesday thursday friday saturday)
  INTERVALS = {
    :monthly => 1,
    :bimonthly => 2,
    :quarterly => 3,
    :semestral => 6
  }
  
  def initialize(options)
    raise ArgumentError, ':every options is required' unless options.key?(:every)
    raise ArgumentError, 'invalid :every option' unless FREQUENCY.include?(options[:every].to_s)
    raise ArgumentError, 'interval should be greater than zero' if options.key?(:interval) && options[:interval].to_i == 0
    
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
        @event = Recurrence::Event.new(:month, @options)
      when :year then
        raise ArgumentError, 'invalid month' unless (1..12).include?(@options[:on].first)
        raise ArgumentError, 'invalid day' unless (1..31).include?(@options[:on].last)
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
  
  def events
    @events ||= begin
      _events = []
      
      loop do
        date = @event.find_next!

        break if date.nil?
        _events << date
      end
      
      _events
    end
  end
  
  def events!
    reset!
    events
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