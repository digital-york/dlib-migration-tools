#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri' #installed by sudo apt install ruby-nokogiri, not by bundle install, but have now added this into bootstrap
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
		#though if a year has two many digits, this will truncate rather than report an error
		date_in.scan(/([\d]{4})/){matches << $~}  #though if a year has two many digits, this will truncate
		#date_in.scan(/([\d]{4}[\s\-\.\/\\\\\Z])/){matches << $~}  #that doesnt work. maybe needs two tests,
		#one showing 4 digits PRECISELY at start followed by non digit, other similar but at end
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
	
	#rake date_manipulation_tasks:test["1976/01/30"]
	def test_normalisation(date)
	    print "input date to test"
		date = date.to_s
		output = normalise_date(date)
		puts "normalised date is:" + output.to_s
	end
	
	
	
	
	#rake date_manipulation_tasks:check_all_date_formats["../data"] for minimal info
	#rake date_manipulation_tasks:check_all_date_formats["../data","more"] for file name and original date 
	#default output to dlib-migration-tools root dir
	def check_all_date_formats(directory_to_check,info_level)
	#def bulk_date_check()
		puts "testing file reading"
		outfile = File.open("corrected_dates_list.txt", "a")
		directory_to_check = directory_to_check.strip
		Dir.foreach(directory_to_check.strip)do |item|
			next if item == '.' or item == '..'
			#filepath = "../data" + "/" + item
			filepath = directory_to_check + "/" + item
			#normalised_date = check_single_file(filepath)
			returned_values = check_single_file(filepath)
			date_in = returned_values[0]
			date_out = returned_values[1]
			if info_level == "more"
				if date_in != date_out
					outfile.puts("FILE:" + item + " DATE IN:" + date_in.to_s + " DATE OUT:" + date_out.to_s )
				end
			else
				if date_in != date_out
					outfile.puts("DATE OUT:" + date_out.to_s )
				end
			end
		end #end iteration through folder		
	end #end test_file_reading
	
		
	
	#default output to dlib-migration-tools root dir
	def check_single_file(filepath)
		doc = File.open(filepath){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}		
		ns = doc.collect_namespaces # doesnt resolve nested namespaces, this fixes that
		# find max dc version
		nums = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",ns)	
		all = nums.to_s
		current = all.rpartition('.').last 
		current_dc_version = 'DC.' + current
		
		#get dates from current dc version only
		date = []
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:date/text()",ns).each do |s|		
			date.push(s.to_s)
			puts "still checking..."
		end
		
		date.each do |d|
			return_values = []
			unchecked_date = d.strip
			normalised_date = normalise_date(d.strip)
			return_values.push(unchecked_date)
			return_values.push(normalised_date)			
			#return normalised_date.to_s
			return return_values
		end			
	end #end test_file_reading1
	
 

	if __FILE__==$0
		d = DateNormaliser.new
		#d.say_hi
		d.test_normalisation()
	end	
end