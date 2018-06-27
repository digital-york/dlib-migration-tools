namespace :create_csv_tasks do
desc "build up csv file from foxml values"

require_relative '../../lib/date_normaliser.rb'
require_relative '../../lib/department_name_normaliser.rb'
require_relative '../../lib/create_csv.rb'

	task :greet do
		puts "greetings from the new csv creation tasks"
	end

	task :test do
		c = CreateCsv.new
		c.say_hi
		c.migrate_a_file
	end

end
