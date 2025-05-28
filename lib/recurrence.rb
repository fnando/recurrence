# frozen_string_literal: true

require_relative "recurrence/namespace"

# The default namespace. If you already have Recurrence constant set on your
# codebase, you can inherit from `Recurrence_` and have your own namespace.
#
#   require "recurrence/namespace"
#
#   class RecurrentEvent < Recurrence_
#   end
#
#   r = RecurrentEvent.new(:every => :day)
#
# Remember require <tt>recurrence/namespace</tt> instead of just <
# tt>recurrence</tt>. If you're using Rails/Bundler or something like that,
# remember to override the <tt>:require</tt> option.
#
#   # Gemfile
#   source :rubygems
#   gem "recurrence", require: "recurrence/namespace"
#
class Recurrence < Recurrence_
end
