class Recurrence::Event
  attr_accessor :start_date

  def initialize(options={})
    every, options = nil, every if every.is_a?(Hash)

    @options    = options
    @date       = options[:starts]
    @start_date = next!
    @date       = nil
    @finished   = false

    validate
  end

  def next!
    return nil if finished?
    return @date = @start_date if @start_date && @date.nil?

    @date = next_in_recurrence

    @finished, @date = true, nil if @date > @options[:until]
    @date
  end

  def next
    return nil if finished?
    @date || @start_date
  end

  def reset!
    @date = nil
  end

  def finished?
    @finished
  end

  private

    def initialized?
      !!@start_date
    end

    def validate
      # Inject custom validations
    end

end
