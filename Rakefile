require 'bundler'
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
#require "cucumber"
#require "cucumber/rake/task"


RSpec::Core::RakeTask.new
# Cucumber::Rake::Task.new("cucumber") do
#   puts "No cucumber features defined yet."
# end

task :default => [:spec] #, :cucumber]
