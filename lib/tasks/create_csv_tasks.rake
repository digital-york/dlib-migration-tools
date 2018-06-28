namespace :create_csv_tasks do
desc "build up csv file from foxml values"

require_relative '../../lib/date_normaliser.rb'
require_relative '../../lib/department_name_normaliser.rb'
require_relative '../../lib/create_csv.rb'

	task :greet do
		puts "greetings from the new csv creation tasks"
	end

	task :batch_make_csv, [:folderpath] do |t, args|
		c = CreateCsv.new
		c.make_csv_from_batch(args[:folderpath])
	end

	task :make_csv, [:filepath] do |t, args|
		c = CreateCsv.new
		c.make_csv_from_single_file(args[:filepath])
	end
end
