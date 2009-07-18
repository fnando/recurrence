class Recurrence
  module Shortcuts
    def daily(options={})
      options[:every] = :day
      new(options)
    end

    def weekly(options)
      options[:every] = :week
      new(options)
    end

    def monthly(options)
      options[:every] = :month
      new(options)
    end

    def yearly(options)
      options[:every] = :year
      new(options)
    end
  end
end
