# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# availableto Rake.
require 'rubocop/rake_task'

RuboCop::RakeTask.new

Dir.glob('lib/tasks/*.rake').each {|r| import r}
