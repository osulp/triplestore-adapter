require "bundler/gem_tasks"
require "rspec/core/rake_task"
Dir.glob('tasks/*.rake').each {|r| load r}

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
