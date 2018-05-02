# encoding: UTF-8

# methods to create the  collection structure and do migrations
class DateManipulation

def say_hi
puts "hi from Datemanipulation"
end

#read in list of dates from text file in various formats, output list of same dates in normalised form
#example call 1) with optional params or 2) defaults only 
#rake date_manipulation_tasks:check_date_normalisation[tmp/yourinputfilename.txt,tmp/youroutputfilename.txt]
#rake date_manipulation_tasks:check_date_normalisation will use defaults 'tmp/examdatesin.txt' and 'tmp/examdatesout.txt'
def run_normalisation_check(input_file_path, output_file_path)
	puts "running the normalisation of all dc:dates listed in " + input_file_path + " outputting to " + output_file_path
	outputfile = File.open( output_file_path, "a")
	inputfile = File.readlines(input_file_path).each do |line|
		date_and_pid = line.strip
		parts = date_and_pid.split(',')
		pid = parts[0]
		date = parts[1]
		newdate = normalise_date_to_year(date)
		if (newdate.length == 4)
			outputfile.puts(newdate) 
		else 
		    outputfile.puts("newdate: " + newdate + " " + " original date: " + date + " PID: " + pid )
		end		
	end	
	puts "finished"
	outputfile.close
end #end run_normalisation_check

#method to ensure date is formatted as a single year yyyy
def normalise_date_to_year(unnormalised_date)
#known variants to normalise
# yyyy
#yyyy-mm
#yyyy mm
#mm yyyy
#mm-yyyy
#yyyy-yyyy
#dd-mm-yyyy
#yyyy-mm-dd */
normalised = ""
 if  /^[0-9]{4}\Z/.match(unnormalised_date)  #already in correct form.  
	normalised = unnormalised_date
 elsif /^[0-9]{4}[-\s][0-9]{2}\Z/.match(unnormalised_date) #yyyy-mm
	normalised = unnormalised_date[0..3]
 elsif /^[0-9]{2}[-\s][0-9]{4}\Z/.match(unnormalised_date) #mm-yyyy
	normalised = unnormalised_date[3..8]
 elsif /^[0-9]{4}[-\s][0-9]{4}\Z/.match(unnormalised_date)  #yyyy-yyyy 
	normalised = unnormalised_date[5..8]
 elsif 	/^[0-9]{4}[-\s][0-9]{2}[-\s][0-9]{2}\Z/.match(unnormalised_date) #yyyy-mm-dd  (actual order of month/day unimportant)	
    normalised = unnormalised_date[0..3]
 elsif 	/^[0-9]{2}[-\s][0-9]{2}[-\s][0-9]{4}\Z/.match(unnormalised_date) #mm-dd-yyyy  (actual order of month/day unimportant)	
	normalised = unnormalised_date[6..9] 
 else
     #return whatever we've found - its better than nothing
	 normalised = unnormalised_date
	 puts "found variant unknown"
 end
    return normalised
end

end # end of class
