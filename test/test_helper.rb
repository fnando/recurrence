require "bundler/setup"
require "minitest/utils"
require "minitest/autorun"

require "recurrence"

Date::DATE_FORMATS[:date] = "%d/%m/%Y"
Time::DATE_FORMATS[:date] = "%d/%m/%Y"

module Minitest
  class Test
    def recurrence(options)
      Recurrence.new(options)
    end

    setup { Recurrence.default_starts_date = nil }
  end
end
