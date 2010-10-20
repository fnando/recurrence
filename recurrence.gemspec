# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "recurrence"

Gem::Specification.new do |s|
  s.name        = "rosetta"
  s.version     = Recurrence::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/recurrence"
  s.summary     = "A simple library to handle recurring events"
  s.description = "A simple library to handle recurring events"

  s.rubyforge_project = "recurrence"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_development_dependency "rspec-rails", ">= 2.0.0"
end
