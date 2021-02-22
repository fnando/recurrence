# frozen_string_literal: true

class Recurrence_
  module Event # :nodoc: all
    require "recurrence/event/base"
    require "recurrence/event/daily"
    require "recurrence/event/monthly"
    require "recurrence/event/weekly"
    require "recurrence/event/yearly"
  end
end
