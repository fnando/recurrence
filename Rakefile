require "rake"
require "jeweler"
require "spec/rake/spectask"
require File.dirname(__FILE__) + "/lib/ofx/version"

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "ofx"
  gem.version = OFX::Version::STRING
  gem.summary = "A simple OFX (Open Financial Exchange) parser built on top of Nokogiri. Currently supports OFX 1.0.2."
  gem.description = <<-TXT
A simple OFX (Open Financial Exchange) parser built on top of Nokogiri. Currently supports OFX 1.0.2.
TXT
  
  gem.authors = ["Nando Vieira"]
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://github.com/fnando/ofx"
  
  gem.has_rdoc = false
  gem.files = %w(Rakefile ofx.gemspec VERSION README.markdown) + Dir["{bin,lib,spec}/**/*"]
	
	gem.add_dependency "nokogiri"
end

desc "Build and install the gem"
desc "Generate gemspec and build gem"
task :build_gem do
  File.open("VERSION", "w+") {|f| f << OFX::Version::STRING }
  
  Rake::Task["gemspec"].invoke
  Rake::Task["build"].invoke
end

Spec::Rake::SpecTask.new {|t| t.spec_opts = ["-c", "-f s"] }
