# frozen_string_literal: true
require "bundler/gem_tasks"
require "rake/testtask"
require_relative "test/dummy/config/application"
require "rubocop/rake_task"
RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/integration/**/*_test.rb", "test/features/**/*_test.rb"]
end

Rails.application.load_tasks

task default: %i[test rubocop]

