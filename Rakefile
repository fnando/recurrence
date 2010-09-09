require "rspec/core/rake_task"
require "lib/recurrence/version"

RSpec::Core::RakeTask.new

begin
  require "jeweler"

  JEWEL = Jeweler::Tasks.new do |gem|
    gem.name = "recurrence"
    gem.version = Recurrence::Version::STRING
    gem.summary = "A simple library to handle recurring events"
    gem.description = ""
    gem.authors = ["Nando Vieira"]
    gem.email = "fnando.vieira@gmail.com"
    gem.homepage = "http://github.com/fnando/recurrence"
    gem.has_rdoc = false
    gem.files = FileList["History.txt", "init.rb", "License.txt", "Rakefile", "README.markdown", "recurrence.gemspec", "{lib,spec}/**/*"]
    gem.add_development_dependency "rspec", ">= 2.0.0"
    gem.add_dependency "activesupport"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "You don't have Jeweler installed, so you won't be able to build gems."
end
