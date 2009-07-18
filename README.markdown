Recurrence
==========

* [http://github.com/fnando/recurrence](http://github.com/fnando/recurrence)

DESCRIPTION:
------------

A simple library to handle recurring events.


INSTALLATION:
-------------

Recurrence can be installed as Rails plugin or gem. To install it as gem, just
run the command 

	sudo gem install fnando-recurrence --source=http://gems.github.com

Sometimes Github just won't build the gem. You can then do the following

	git clone git://github.com/fnando/recurrence.git
	cd recurrence
	rake gem:install

If you prefer it as a plugin, just run the command

	script/plugin install git://github.com/fnando/recurrence.git

USAGE:
------
	
	require 'rubygems'
	require 'recurrence'
	
	# Daily
	r = Recurrence.new(:every => :day)
	r = Recurrence.new(:every => :day, :interval => 9)
	
	# Weekly
	r = Recurrence.new(:every => :week, :on => :friday)
	r = Recurrence.new(:every => :week, :on => 5)
	r = Recurrence.new(:every => :week, :on => :friday, :interval => 2)
	
	# Monthly by month day
	r = Recurrence.new(:every => :month, :on => 15)
	r = Recurrence.new(:every => :month, :on => 31)
	r = Recurrence.new(:every => :month, :on => 7, :interval => 2)
	r = Recurrence.new(:every => :month, :on => 7, :interval => :monthly)
	r = Recurrence.new(:every => :month, :on => 7, :interval => :bimonthly)
	
	# Monthly by week day
	r = Recurrence.new(:every => :month, :on => :first, :weekday => :sunday)
	r = Recurrence.new(:every => :month, :on => :third, :weekday => :monday)
	r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday)
	r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :interval => 2)
	r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :interval => :quarterly)
	r = Recurrence.new(:every => :month, :on => :last,  :weekday => :friday, :interval => :semesterly)
	
	# Yearly
	r = Recurrence.new(:every => :year, :on => [7, 4]) # => [month, day]
	r = Recurrence.new(:every => :year, :on => [10, 31], :interval => 3)
	r = Recurrence.new(:every => :year, :on => [:jan, 31])
	r = Recurrence.new(:every => :year, :on => [:january, 31])
	
	# Limit recurrence
	# :starts defaults to Date.today
	# :until defaults to 2037-12-31
	r = Recurrence.new(:every => :day, :starts => Date.today)
	r = Recurrence.new(:every => :day, :until => '2010-01-31')
	r = Recurrence.new(:every => :day, :starts => Date.today, :until => '2010-01-31')
	
	# Getting an array with all events
	r.events.each {|date| puts date.to_s }  # => Memoized array
	r.events!.each {|date| puts date.to_s } # => reset items cache and re-execute it
	r.events(:starts => '2009-01-01').each {|date| puts date.to_s }
	r.events(:until => '2009-01-10').each {|date| puts date.to_s }
	r.events(:starts => '2009-01-05', :until => '2009-01-10').each {|date| puts date.to_s }
	
	# Iterating events
	r.each { |date| puts date.to_s } # => Use items method
	r.each! { |date| puts date.to_s } # => Use items! method
	
	# Check if a date is included
	r.include?(Date.today) # => true or false
	r.include?('2008-09-21')
	
	# Get next available date
	r.next 	# => Keep the original date object
	r.next! # => Change the internal date object to the next available date

MAINTAINER
----------
 
* Nando Vieira (<http://simplesideias.com.br/>)

CONTRIBUTORS
------------
 
* José Valim (<http://josevalim.blogspot.com/>)

LICENSE:
--------

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
