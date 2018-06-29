namespace :department_manipulation_tasks do
desc "department name normalisation tools"

require_relative '../../lib/department_name_normaliser.rb'

	task :greet do
		puts "greetings from the new department manipulation tasks"
	end

	task :test_filter, [:loc_value] do |t, args|
		d = DepartmentNameNormaliser.new
		f = d.filter_department_values(args[:loc_value])
		puts f
	end

	task :test, [:filepath] do |t, args|
		puts args[:filepath]
		d = DepartmentNameNormaliser.new
		d.say_hi
		d.check_single_file(args[:filepath])
	end

	task :batch_check_department_names, [:directory_path,:info_level] do |t, args|
		puts args[:directory_path]
		args.with_defaults(:info_level => 'less')
		d = DepartmentNameNormaliser.new
		d.check_folder(args[:directory_path],args[:info_level])
	end

end
