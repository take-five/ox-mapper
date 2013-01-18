require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

# Setup compile task
Rake::ExtensionTask.new('cstack')

# Setup spec task
spec_task = RSpec::Core::RakeTask.new
# add `compile` prerequisite
task spec_task.name => :compile