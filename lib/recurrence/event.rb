class Recurrence
  module Event
    autoload :Base,     "recurrence/event/base"
    autoload :Daily,    "recurrence/event/daily"
    autoload :Monthly,  "recurrence/event/monthly"
    autoload :Weekly,   "recurrence/event/weekly"
    autoload :Yearly,   "recurrence/event/yearly"
  end
end
