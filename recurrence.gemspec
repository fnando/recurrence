# WARNING : RAKE AUTO-GENERATED FILE. DO NOT MANUALLY EDIT!
# RUN : 'rake gem:update_gemspec'

Gem::Specification.new do |s|
  s.authors = ["Nando Vieira"]
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 0"
  s.has_rdoc = false
  s.files = ["init.rb",
 "Rakefile",
 "recurrence.gemspec",
 "History.txt",
 "License.txt",
 "README.markdown",
 "lib/recurrence",
 "lib/recurrence/base.rb",
 "lib/recurrence/event.rb",
 "lib/recurrence.rb"]
  s.email = ["fnando.vieira@gmail.com"]
  s.version = "0.0.6"
  s.homepage = "http://github.com/fnando/recurrence"
  s.name = "recurrence"
  s.summary = "A simples library that handles recurring events"
  s.add_dependency "rubigen", ">= 0"
  s.add_dependency "activesupport", ">= 2.1.1"
  s.bindir = "bin"
end