# Recurrence

A simple library to handle recurring events.

[![Travis-CI](https://travis-ci.org/fnando/recurrence.png)](https://travis-ci.org/fnando/recurrence)
[![CodeClimate](https://codeclimate.com/github/fnando/recurrence.png)](https://codeclimate.com/github/fnando/recurrence)
[![Gem](https://img.shields.io/gem/v/recurrence.svg)](https://rubygems.org/gems/recurrence)
[![Gem](https://img.shields.io/gem/dt/recurrence.svg)](https://rubygems.org/gems/recurrence)

## Installation

    gem install recurrence

## Usage

```ruby
require "rubygems"
require "recurrence"

# Daily
r = Recurrence.new(:every => :day)
r = Recurrence.new(:every => :day, :interval => 9)
r = Recurrence.new(:every => :day, :repeat => 7)
r = Recurrence.daily(options = {})

# Weekly
r = Recurrence.new(:every => :week, :on => 5)
r = Recurrence.new(:every => :week, :on => :monday)
r = Recurrence.new(:every => :week, :on => [:monday, :friday])
r = Recurrence.new(:every => :week, :on => [:monday, :wednesday, :friday])
r = Recurrence.new(:every => :week, :on => :friday, :interval => 2)
r = Recurrence.new(:every => :week, :on => :friday, :repeat => 4)
r = Recurrence.weekly(:on => :thursday)

# Monthly by month day(s)
r = Recurrence.new(:every => :month, :on => 15)
r = Recurrence.new(:every => :month, :on => 31)
r = Recurrence.new(:every => :month, :on => [15, 31])
r = Recurrence.new(:every => :month, :on => 7, :interval => 2)
r = Recurrence.new(:every => :month, :on => 7, :interval => :monthly)
r = Recurrence.new(:every => :month, :on => 7, :interval => :bimonthly)
r = Recurrence.new(:every => :month, :on => 7, :repeat => 6)
r = Recurrence.monthly(:on => 31)

# Monthly by week day
r = Recurrence.new(:every => :month, :on => :first, :weekday => :sunday)
r = Recurrence.new(:every => :month, :on => :third, :weekday => :monday)
r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday)
r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :interval => 2)
r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :interval => :quarterly)
r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :interval => :semesterly)
r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :repeat => 3)

# Yearly
r = Recurrence.new(:every => :year, :on => [7, 4]) # => [month, day]
r = Recurrence.new(:every => :year, :on => [10, 31], :interval => 3)
r = Recurrence.new(:every => :year, :on => [:jan, 31])
r = Recurrence.new(:every => :year, :on => [:january, 31])
r = Recurrence.new(:every => :year, :on => [10, 31], :repeat => 3)
r = Recurrence.yearly(:on => [:january, 31])

# Limit recurrence
# :starts defaults to Date.today
# :until defaults to 2037-12-31
r = Recurrence.new(:every => :day, :starts => Date.today)
r = Recurrence.new(:every => :day, :until => '2010-01-31')
r = Recurrence.new(:every => :day, :starts => Date.today, :until => '2010-01-31')

# Generate a collection of events which always includes a final event with the given through date
# :through defaults to being unset
r = Recurrence.new(:every => :day, :through => '2010-01-31')
r = Recurrence.new(:every => :day, :starts => Date.today, :through => '2010-01-31')

# Remove a date in the series on the given except date(s)
# :except defaults to being unset
r = Recurrence.new(:every => :day, :except => '2010-01-31')
r = Recurrence.new(:every => :day, :except => [Date.today, '2010-01-31'])

# Override the next date handler
r = Recurrence.new(:every => :month, :on => 1, :handler => Proc.new { |day, month, year| raise("Date not allowed!") if year == 2011 && month == 12 && day == 31 })

# Shift the recurrences to maintain dates around boundaries (Jan 31 -> Feb 28 -> Mar 28)
# Shift cannot be used with multiple month days e.g: :on => [1,15]
r = Recurrence.new(:every => :month, :on => 31, :shift => true)

# Getting an array with all events
r.events.each {|date| puts date.to_s }  # => Memoized array
r.events!.each {|date| puts date.to_s } # => reset items cache and re-execute it
r.events(:starts => '2009-01-01').each {|date| puts date.to_s }
r.events(:until => '2009-01-10').each {|date| puts date.to_s }
r.events(:through => '2009-01-10').each {|date| puts date.to_s }
r.events(:starts => '2009-01-05', :until => '2009-01-10').each {|date| puts date.to_s }

# Iterating events
r.each { |date| puts date.to_s } # => Use items method
r.each! { |date| puts date.to_s } # => Use items! method

# Check if a date is included
r.include?(Date.today) # => true or false
r.include?('2008-09-21')

# Get next available date
r.next   # => Keep the original date object
r.next! # => Change the internal date object to the next available date
```

## Troubleshooting

If you're having problems because already have a class/module called Recurrence that is conflicting with this gem, you can require the namespace and create a class that inherits from `Recurrence_`.

```ruby
require "recurrence/namespace"

class RecurrentEvent < Recurrence_
end

r = RecurrentEvent.new(:every => :day)
```

If you're using Rails/Bundler or something like that, remember to override the `:require` option.

```ruby
# Gemfile
source "https://rubygems.org"

gem "recurrence", :require => "recurrence/namespace"
```

## Maintainer

* Nando Vieira (http://nandovieira.com)

## Contributors

* https://github.com/fnando/recurrence/graphs/contributors

## License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
