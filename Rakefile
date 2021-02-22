# frozen_string_literal: true

require "bundler"
require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rake/testtask"
Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = false
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %i[test rubocop]
