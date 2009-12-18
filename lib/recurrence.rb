require 'rubygems'
require 'date'
require 'active_support'

dirname = File.dirname(__FILE__)
require dirname + '/recurrence/base'
require dirname + '/recurrence/shortcuts'
require dirname + '/recurrence/event'
require dirname + '/recurrence/event/daily'
require dirname + '/recurrence/event/weekly'
require dirname + '/recurrence/event/monthly'
require dirname + '/recurrence/event/yearly'

class Recurrence
  include Base
  extend Shortcuts
end
