# frozen_string_literal: true
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/test_application/test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

load "test/test_application/Rakefile"

task default: %i[test rubocop]

