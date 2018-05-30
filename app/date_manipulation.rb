# encoding: UTF-8
require 'cgi'

# methods to create the  collection structure and do migrations
class DateManipulation

def say_hi
puts "hi from Datemanipulation"
end

#read in list of dates from text file in various formats, output list of same dates in normalised form
#requires local machine ip permissions to be granted on remote server for fedora/risearch
#limit and datelist_path params are optional, if not set will default to unlimited and tmp/datelistin.txt. if setting datelist_path only, leave comma to mark param positions thus  
#rake date_manipulation_tasks:all_in_one_date_normalisation_check[user,password,server_url,,tmp/yourinputfilename.txt]
def all_in_one_date_normalisation_check(user,password,server_url,limit,datelist_path)	
	#get the date list by risearch	
	get_datelist(user,password,server_url,limit,datelist_path)	
	nameparts = datelist_path.split('.txt')
	newname = nameparts[0] + "_normalised.txt"
	normalised_datelist = File.open( newname, "a")
	#normalise each date listed, output location data for unhandled variants
	dates = File.readlines(datelist_path).drop(1).each do |line| #ignore the header line
		date_and_pid = line.strip
		parts = date_and_pid.split(',')
		pid = parts[0]
		date = parts[1]
		newdate = normalise_date_to_year(date)
		if (newdate.length == 4)
			normalised_datelist.puts(newdate) 
		else 
		    normalised_datelist.puts("newdate: " + newdate + " " + " original date: " + date + " PID: " + pid )
		end		
	end	
	puts "finished"
	normalised_datelist.close
end #end run_normalisation_check


#read in list of dates from text file in various formats, output list of same dates in normalised form
#example call 1) with optional params or 2) defaults only 
#rake date_manipulation_tasks:check_date_normalisation[tmp/yourinputfilename.txt]
#rake date_manipulation_tasks:check_date_normalisation will use default 'tmp/datelistin.txt' 
def run_normalisation_check(input_file_path)	
	nameparts = input_file_path.split('.txt')
	newname = nameparts[0] + "_normalised.txt"
	normalised_datelist = File.open( newname, "a")
	inputfile = File.readlines(input_file_path).drop(1).each do |line| #ignore the header line
		date_and_pid = line.strip
		parts = date_and_pid.split(',')
		pid = parts[0]
		date = parts[1]
		newdate = normalise_date_to_year(date)
		if (newdate.length == 4)
			normalised_datelist.puts(newdate) 
		else 
		    normalised_datelist.puts("newdate: " + newdate + " " + " original date: " + date + " PID: " + pid )
		end		
	end	
	puts "finished"
	normalised_datelist.close
end #end run_normalisation_check


#issues: requires access allowed to virtual host on fedora server - do we want this from a development machine?
#needs server calling it to be on the apache access control list
# if specified, optional input_file_path in run_normalisation_check must match
#limit is also optional, default for live run is unlimited, mark position with commas if datelist_path specified but not limit
#rake date_manipulation_tasks:get_datelist[username,password,server_name,<limit>,<output_file_name>]
#examples #rake date_manipulation_tasks:get_datelist[jane,janes_password,'https://server.uhk.ac.uk',10,'tmp/myfolder/myfile.txt']
#rake date_manipulation_tasks:get_datelist[jane,janes_password,'https://server.uhk.ac.uk',,'tmp/myfolder/myfile.txt']
def get_datelist(user,password,server_url,limit,datelist_path)
basic_ri_url = server_url + "/fedora/risearch?type=tuples&lang=itql&format=CSV"
query = CGI.escape("select $object $date  
from <#ri>
where  
$object <dc:date> $date
and ( $object <fedora-model:hasModel> <fedora:york:CModel-Thesis> or $object <fedora-model:hasModel> <fedora:york:CModel-ExamPaper> or $object <dc:type> 'Thesis' or $object <dc:type> 'ExamPaper')") 

#most of the time we will want to remove the limit when running it live.
if !(limit=="unlimited")	
	curl_output = `curl -u #{user}:#{password} -X GET  '#{basic_ri_url}&limit=#{limit}&query=#{query}'`
else
	curl_output = `curl -u #{user}:#{password} -X GET  '#{basic_ri_url}&query=#{query}'`	
end 	
File.write(datelist_path,curl_output)
end 

#method to ensure date is formatted as a single year yyyy
#runs against a single string representing a date
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
	 puts "found unknown variant, normalised left as " + normalised
 end
   
    return normalised
end

end # end of class
