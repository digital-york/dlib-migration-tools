namespace :date_manipulation_tasks do
desc "date manipulation tools"


require_relative '../../app/date_manipulation.rb'


task :greet do
	puts "greetings from the date manipulation tasks"
end



#with two optionals if you only give it one optional, it gets confused and assumes the one its got is the first one. so you must mark the unused parameter position with a comma in the command line call
#test the risearch for dates
task :get_datelist, [:user,:password,:server_url,:limit,:datelist]  => :environment do|t, args|
	args.with_defaults(:datelist => 'tmp/datelistin.txt', :limit => 'unlimited')
	puts "Args were: #{args}"
	d = DateManipulation.new
	d.get_datelist(args[:user],args[:password],args[:server_url],args[:limit],args[:datelist])
end

#test the date normalisation. datelist is optional param for list of unnormalised dates, will look for default if not specified.
task :check_date_normalisation, [:datelist]  => :environment do|t, args|
    args.with_defaults(:datelist => 'tmp/datelistin.txt')
	puts "Args were: #{args}"
	d = DateManipulation.new
	d.run_normalisation_check(args[:datelist])
end

#all in one method for testing  date normalisation. just one command line call but a few parameters to enter. limit and output_to optional, but if providing only output_to, mark place with comma
task :all_in_one_date_normalisation_check, [:user,:password,:server_url,:limit,:output_to]  => :environment do|t, args|
    args.with_defaults(:output_to => 'tmp/datelistin.txt', :limit => 'unlimited')
	d = DateManipulation.new
	d.all_in_one_date_normalisation_check(args[:user],args[:password],args[:server_url],args[:limit],args[:output_to])
	puts "all done"
end

end #end of tasks
