require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format progress"
end

desc 'pry console for gem'
task :c do
  require 'pry'
  require 'lurker'
  require 'lurker/cli'
  ARGV.clear
  Pry.start
end

task :default => [:spec]

