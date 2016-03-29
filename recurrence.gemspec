require "./lib/recurrence/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.0"
  s.name        = "recurrence"
  s.version     = SimplesIdeias::Recurrence::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/recurrence"
  s.summary     = "A simple library to handle recurring events"
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "i18n"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rake"
end
