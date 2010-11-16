require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

require "rake/rdoctask"
Rake::RDocTask.new do |rd|
 rd.main = "README.rdoc"
 rd.rdoc_files.include("README.rdoc", "lib/**/*.rb", "History.txt", "License.txt")
end
