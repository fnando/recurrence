# frozen_string_literal: true

require "date"
require "time"

class Recurrence_
  require_relative "refinements/time"
  require_relative "refinements/date"
  require_relative "handler/fall_back"
  require_relative "event/base"
  require_relative "event/daily"
  require_relative "event/monthly"
  require_relative "event/weekly"
  require_relative "event/yearly"
  require_relative "version"

  include Enumerable

  def self.extended(target)
    target.default_starts_date = default_starts_date
  end

  # This is the available frequency options accepted by
  # <tt>:every</tt> option.
  FREQUENCY = %w[day week month year].freeze

  # This is the default callable that is used as the current date.
  # If `Date.current` is available, use it. Otherwise, fall back
  # to `Date.today`.
  DEFAULT_STARTS_DATE = lambda do
    Date.respond_to?(:current) ? Date.current : Date.today
  end

  attr_reader :event, :options

  # Return the default starting date.
  #
  #   Recurrence.default_starts_date
  #   #=> <Date>
  #
  def self.default_starts_date
    @default_starts_date.call
  end

  # Set the default starting date globally.
  # Can be a proc or a string.
  #
  #   Recurrence.default_starts_date = proc { Date.current }
  #
  def self.default_starts_date=(date)
    unless date.respond_to?(:call)
      raise ArgumentError, "default_starts_date must be a proc"
    end

    @default_starts_date = date
  end

  self.default_starts_date = DEFAULT_STARTS_DATE

  # Return the default ending date. Defaults to 2037-12-31.
  #
  #   Recurrence.default_until_date
  #
  def self.default_until_date
    @default_until_date ||= Date.new(2037, 12, 31)
  end

  # Set the default ending date globally.
  # Can be a date or a string recognized by Date#parse.
  #
  #   Recurrence.default_until_date = "2012-12-31"
  #   Recurrence.default_until_date = Date.tomorrow
  #
  def self.default_until_date=(date)
    @default_until_date = as_date(date)
  end

  # Create a daily recurrence.
  #
  #   Recurrence.daily
  #   Recurrence.daily(interval: 2) #=> every 2 days
  #   Recurrence.daily(starts: 3.days.from_now)
  #   Recurrence.daily(until: 10.days.from_now)
  #   Recurrence.daily(repeat: 5)
  #   Recurrence.daily(except: Date.tomorrow)
  #
  def self.daily(options = {})
    options[:every] = :day
    new(options)
  end

  # Create a weekly recurrence.
  #
  #   Recurrence.weekly(on: 5) #=> 0 = sunday, 1 = monday, ...
  #   Recurrence.weekly(on: :saturday)
  #   Recurrence.weekly(on: [sunday, :saturday])
  #   Recurrence.weekly(on: :saturday, interval: 2)
  #   Recurrence.weekly(on: :saturday, repeat: 5)
  #
  def self.weekly(options = {})
    options[:every] = :week
    new(options)
  end

  # Create a monthly recurrence.
  #
  #   Recurrence.monthly(on: 15) #=> every 15th day
  #   Recurrence.monthly(on: :first, :weekday => :sunday)
  #   Recurrence.monthly(on: :second, :weekday => :sunday)
  #   Recurrence.monthly(on: :third, :weekday => :sunday)
  #   Recurrence.monthly(on: :fourth, :weekday => :sunday)
  #   Recurrence.monthly(on: :fifth, :weekday => :sunday)
  #   Recurrence.monthly(on: :last, :weekday => :sunday)
  #   Recurrence.monthly(on: 15, interval: 2)
  #   Recurrence.monthly(on: 15, interval: :monthly)
  #   Recurrence.monthly(on: 15, interval: :bimonthly)
  #   Recurrence.monthly(on: 15, interval: :quarterly)
  #   Recurrence.monthly(on: 15, interval: :semesterly)
  #   Recurrence.monthly(on: 15, repeat: 5)
  #
  # The <tt>:on</tt> option can be one of the following:
  #
  #   * :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday
  #   * :sun, :mon, :tue, :wed, :thu, :fri, :sat
  #
  def self.monthly(options = {})
    options[:every] = :month
    new(options)
  end

  # Create a yearly recurrence.
  #
  #   Recurrence.yearly(on: [7, 14]) #=> every Jul 14
  #   Recurrence.yearly(on: [7, 14], interval: 2) #=> every 2 years on Jul 14
  #   Recurrence.yearly(on: [:jan, 14], interval: 2)
  #   Recurrence.yearly(on: [:january, 14], interval: 2)
  #   Recurrence.yearly(on: [:january, 14], repeat: 5)
  #
  def self.yearly(options = {})
    options[:every] = :year
    new(options)
  end

  # Initialize a recurrence object. All options from shortcut methods
  # (Recurrence.daily, Recurrence.monthly, and so on) and requires the
  # <tt>:every</tt> option to be one of these options: <tt>:day</tt>,
  # <tt>:week</tt>, <tt>:month</tt>, or <tt>:year</tt>.
  #
  #   Recurrence.new(every: :day)
  #   Recurrence.new(every: :week, on: :sunday)
  #   Recurrence.new(every: :month, on: 14)
  #   Recurrence.new(every: :year, on: [:jan, 14])
  #
  def initialize(options)
    validate_initialize_options(options)

    if options[:except]
      options[:except] = [options[:except]].flatten.map do |d|
        as_date(d)
      end
    end

    @options = options
    @_options = initialize_dates(options.dup)
    @_options[:interval] ||= 1
    @_options[:handler] ||= Handler::FallBack

    @event = initialize_event(@_options[:every])
  end

  # Reset the recurrence cache, returning to the first available date.
  def reset!
    @event.reset!
    @events = nil
  end

  # Check if a given date can be retrieve from the current recurrence options.
  #
  #   r = Recurrence.weekly(on: :sunday)
  #   r.include?("2010-11-16")
  #   #=> false, because "2010-11-16" is monday
  #
  def include?(required_date)
    required_date = as_date(required_date)

    if required_date < @_options[:starts] || required_date > @_options[:until]
      return false
    end

    each do |date|
      return true if date == required_date
    end

    false
  end

  # Return the next date in recurrence, without changing the internal date
  # object.
  #
  #   r = Recurrence.weekly(on: :sunday, starts: "2010-11-15")
  #   r.next #=> Sun, 21 Nov 2010
  #   r.next #=> Sun, 21 Nov 2010
  #
  def next
    @event.next
  end

  # Return the next date in recurrence, and changes the internal date object.
  #
  #   r = Recurrence.weekly(on: :sunday, starts: "2010-11-15")
  #   r.next! #=> Sun, 21 Nov 2010
  #   r.next! #=> Sun, 28 Nov 2010
  #
  def next!
    @event.next!
  end

  # Return an array with all dates within a given recurrence, caching the
  # result.
  #
  #   r = Recurrence.daily(starts: "2010-11-15", until: "2010-11-20")
  #   r.events
  #
  # The return will be
  #
  #   [
  #     [0] Mon, 15 Nov 2010,
  #     [1] Tue, 16 Nov 2010,
  #     [2] Wed, 17 Nov 2010,
  #     [3] Thu, 18 Nov 2010,
  #     [4] Fri, 19 Nov 2010,
  #     [5] Sat, 20 Nov 2010
  # ]
  #
  def events(options = {})
    options[:starts] = as_date(options[:starts])
    options[:until]  = as_date(options[:until])
    options[:through]  = as_date(options[:through])
    options[:repeat] ||= @options[:repeat]
    options[:except] ||= @options[:except]

    reset! if options[:starts] || options[:until] || options[:through]

    @events ||= [].tap do |list|
      loop do
        date = @event.next!

        break unless date

        valid_start = options[:starts].nil? || date >= options[:starts]
        valid_until = options[:until].nil?  || date <= options[:until]
        valid_except = options[:except].nil? || !options[:except].include?(date)
        list << date if valid_start && valid_until && valid_except

        stop_repeat = options[:repeat] && list.size == options[:repeat]
        stop_until = options[:until] && options[:until] <= date
        stop_through = options[:through] && options[:through] <= date

        break if stop_until || stop_repeat || stop_through
      end
    end
  end

  # Works like Recurrence::Namespace#events, but removes the
  # cache first.
  def events!(options = {})
    reset!
    events(options)
  end

  # Iterate in all events between <tt>:starts</tt> and <tt>:until</tt> options.
  #
  #   r = Recurrence.daily(starts: "2010-11-15", until: "2010-11-16")
  #   r.each do |date|
  #     puts date
  #   end
  #
  # This will print
  #
  #   Sun, 15 Nov 2010
  #   Sun, 16 Nov 2010
  #
  # When called without a block, it will return a Enumerator.
  #
  #   r.each
  #   #=> #<Enumerator: [Mon, 15 Nov 2010, Tue, 16 Nov 2010]:each>
  #
  def each(&)
    events.each(&)
  end

  # Works like Recurrence::Namespace#each, but removes the cache first.
  def each!(&)
    reset!
    each(&)
  end

  private def validate_initialize_options(options)
    raise ArgumentError, ":every option is required" unless options.key?(:every)

    return if FREQUENCY.include?(options[:every].to_s)

    raise ArgumentError, ":every option is invalid"
  end

  private def initialize_event(type)
    case type.to_sym
    when :day
      Event::Daily.new(@_options)
    when :week
      Event::Weekly.new(@_options)
    when :month
      Event::Monthly.new(@_options)
    when :year
      Event::Yearly.new(@_options)
    end
  end

  private def initialize_dates(options) # :nodoc:
    %i[starts until through].each do |name|
      options[name] = as_date(options[name])
    end

    options[:starts] ||= self.class.default_starts_date
    options[:until]  ||= self.class.default_until_date

    options
  end

  private def as_date(input) # :nodoc:
    case input
    when Time
      input.to_date
    when String
      Date.parse(input)
    else
      input
    end
  end
end
