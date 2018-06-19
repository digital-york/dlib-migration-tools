namespace :department_manipulation_tasks do
desc "department name normalisation tools"

require_relative '../../lib/department_name_normaliser.rb'

	task :greet do
		puts "greetings from the new department manipulation tasks"
	end

	task :say_hi do
		d = DepartmentNameNormaliser.new
		d.say_hi
	end

	task :test, [:filepath] do |t, args|
		puts args[:filepath]
		param = args[:filepath]
		d = DepartmentNameNormaliser.new
		d.say_hi
		d.check_single_file(args[:filepath])
	end

	#task :check_all_department_names, [:directory_path,:info_level] do |t, args|
	task :check_all_department_names, [:directory_path] do |t, args|
		puts args[:directory_path]
		#args.with_defaults(:info_level => 'less')
		d = DepartmentNameNormaliser.new
		d.check_folder(args[:directory_path])
		#d.check_folder(args[:directory_path],args[:info_level])
	end

	#task :check_all_date_formats, [:directory_path,:info_level] do |t, args|
	#	puts args[:directory_path]
	#	args.with_defaults(:info_level => 'less')
	#	d = DateNormaliser.new
	#	d.check_all_date_formats(args[:directory_path],args[:info_level])
	#end

end
