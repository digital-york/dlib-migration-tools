#!/usr/bin/env ruby
class DateNormaliser
	def initialize
	   puts "initialising DateNormaliser"
	end
	
	def say_hi	
	    puts "hodor!"
	end
	
	
	#this can just look for 4 digit groups, and expect either one or two.
	def get_year(unnormalised_date)
		normalised = ""
		date_in = unnormalised_date
		matches = []
		date_in.scan(/([\d]{4})/){matches << $~}
		if matches.size == 1
			normalised = matches[0].to_s
		elsif matches.size == 2
			normalised = matches[1].to_s
		else
			normalised = "no match"
		end	
	end
	
	#what will happen if they have used the 1066-2001 format ie a year range? it will interpret second year as the month - oops
	#take the string for the entire date and  return just the month  if it is specified. zero pad if single digit
	def get_month(unnormalised_date)		
		month = ""		
	    # if its a year range dont proceed further
		if /[\d]{4}[\s\-\.\/\\\\][\d]{4}/.match(unnormalised_date.strip)
		   return month
		end
		#year is at start so month will be first pair of digits  if present
		#needs a total of 4 backslashes to escape \ used as a date delimiter!
		if /^[0-9]{4}[\s\-\.\/\\\\]([\d]{1,2})/.match(unnormalised_date.strip)
			month = $1	
		#year is at end so month will immediately precede the year
		#needs a total of 4 backslashes to escape \ used as a date delimiter!
		elsif /([\d]{1,2})[\s\-\.\/\\\\][0-9]{4}\Z/.match(unnormalised_date.strip)		
			month = $1
		end
		if month.length ==1
		 month = "0" + month
		end
		return month
	end
	
	#take the string for the entire date and  return just the month  if it is specified. zero pad if single digit
	def get_day(unnormalised_date)
		day = ""
		# if its a year range dont proceed further
		if /[\d]{4}[\s\-\.\/\\\\][\d]{4}/.match(unnormalised_date.strip)
		   return day
		end
		#year is at start so day will be a second pair of digits if present. wont be present without a month
		#needs a total of 4 backslashes to escape \ used as a date delimiter!
		if /^[0-9]{4}[\s\-\.\/\\\\][\d]{1,2}[\s\-\.\/\\\\]([\d]{1,2})/.match(unnormalised_date.strip)
			day = $1	
		#year is at end so day will be first of two pairs of digits if present. it wont be present without a month.
		#needs a total of 4 backslashes to escape \ used as a date delimiter!
		elsif /([\d]{1,2})[\s\-\.\/\\\\][\d]{1,2}[\s\-\.\/\\\\][0-9]{4}\Z/.match(unnormalised_date.strip)
			day = $1
		end
		if day.length ==1
		 day = "0" + day
		end
		return day
	end
	
	#method to put various date variants found in yodl into standard international date format yyyy-mm-dd
	#however month or day may not be provided in which case just supply elements which are there
	#runs against a single string representing a date
	#known variants to normalise
	# yyyy
	#yyyy-mm
	#yyyy mm
	#mm yyyy
	#mm-yyyy
	#yyyy-yyyy
	#dd-mm-yyyy
	#yyyy-mm-dd
	def normalise_date(unnormalised_date)
	normalised = "no match"	
	#get year
	year = get_year(unnormalised_date)
	if year == "no match"
		puts "found unknown variant, input was " + unnormalised_date
		return normalised
	else
		normalised = year
	end	
	#look for month, which may sometimes be present 
	month = get_month(unnormalised_date)
	
	day = get_day(unnormalised_date)
	if month.length > 0
		normalised = normalised. + "-" + month
		#there may in addition be a day
		if day.length > 0 
			normalised = normalised. + "-" + day
		end	
	end	
		return normalised
	end #end normalise_date method
	
	def test_normalisation()
	    print "input date to test"
		date = gets
		output = normalise_date(date)
		puts "normalised date is:" + output.to_s
	end
	
 # end class

	if __FILE__==$0
		d = DateNormaliser.new
		d.say_hi
		d.test_normalisation()
	end	
end