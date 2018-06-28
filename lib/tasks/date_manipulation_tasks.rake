namespace :date_manipulation_tasks do
desc "date normalisation tools"

require_relative '../../lib/date_normaliser.rb'

	task :greet do
		puts "greetings from the new date manipulation tasks"
	end

	task :test, [:date] do |t, args|
		puts args[:date]		
		d = DateNormaliser.new
		d.say_hi
		d.test_normalisation(args[:date])
	end

	task :check_all_date_formats, [:directory_path,:info_level] do |t, args|
		puts args[:directory_path]
		args.with_defaults(:info_level => 'less')
		d = DateNormaliser.new
		d.check_all_date_formats(args[:directory_path],args[:info_level])
	end

end
