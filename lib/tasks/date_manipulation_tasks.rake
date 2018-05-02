namespace :date_manipulation_tasks do
desc "date manipulation tools"


require_relative '../../app/date_manipulation.rb'


task :greet do
	puts "greetings from the date manipulation tasks"
end


#test the date normalisation
#task :check_date_normalisation, [:datelist,:outputfile]  => :environment do|t, args|
#puts "Args were: #{args}"
#	d = DateManipulation.new
#	d.run_normalisation_check(args[:datelist],args[:outputfile])
#end

#test the date normalisation
task :check_date_normalisation, [:datelist,:outputfile]  => :environment do|t, args|
    args.with_defaults(:datelist => 'tmp/examdatesin.txt', :outputfile => 'tmp/examdatesout.txt')
	puts "Args were: #{args}"
	d = DateManipulation.new
	d.run_normalisation_check(args[:datelist],args[:outputfile])
end

end #end of tasks