module SimplesIdeias
  class Recurrence
    module Event # :nodoc: all
      autoload :Base,     "recurrence/event/base"
      autoload :Daily,    "recurrence/event/daily"
      autoload :Monthly,  "recurrence/event/monthly"
      autoload :Weekly,   "recurrence/event/weekly"
      autoload :Yearly,   "recurrence/event/yearly"
    end
  end
end
