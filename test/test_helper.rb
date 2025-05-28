# frozen_string_literal: true

require "simplecov"

SimpleCov.start

require "bundler/setup"
require "minitest/utils"
require "minitest/autorun"

require "recurrence"

module Minitest
  class Test
    module Ext
      def advance_months(months, date = Date.today)
        date >> months
      end

      def advance_days(days, date = Date.today)
        date + days
      end

      def advance_years(years, date = Date.today)
        date >> (years * 12)
      end

      def advance_weeks(weeks, date = Date.today)
        date + (weeks * 7)
      end
    end

    include Ext
    extend Ext

    def recurrence(options)
      Recurrence.new(options)
    end

    setup do
      Recurrence.default_starts_date = Recurrence::DEFAULT_STARTS_DATE
    end

    def self.advance_months(months, date = Date.today)
      date >> months
    end
  end
end
