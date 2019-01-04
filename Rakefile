# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# availableto Rake.

task :default do
  puts 'USAGE'
  puts 'Contains various tasks to support data migration from fedora3 '
  puts 'repositories. '
  puts 'Current tasks identify records in the Theses and Exam Papers '
  puts 'collections respectively, export the foxml files from the repository,'
  puts 'and rewrite the important metadata into a single csv file, one record '
  puts 'per line '
  puts 'Tasks are defined in lib/tasks/metadata_extraction_tasks.rake'
  puts 'Call tasks using the following syntax '
  puts 'rake  metadata_extraction_tasks:TASK_NAME[<"PARAM_1">,<"PARAM_2">]'
  puts 'prepend calls to rake tasks with bundle exec to use local gems only'
  puts 'thus: bundle exec rake metadata_extraction_tasks:TASK_NAME'
  puts 'to see available  tasks and their parameters, run rake --tasks | cat'
  puts 'to see detailed descriptions of tasks and their parameters, '
  puts 'open lib/tasks/metadata_extraction_tasks.rake '
end

Dir.glob('lib/tasks/*.rake').each {|r| import r}
