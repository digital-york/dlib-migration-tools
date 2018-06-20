#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri'
class DepartmentNameNormaliser
	def initialize
	   puts "initialising DepartmentNameNormaliser"
	end

	def say_hi
	    puts "hi! from department normaliser"
	end


	def check_folder(folderpath)
 		#outfile = File.open("corrected_dates_list.txt", "a")
 		directory_to_check = folderpath.strip
 		Dir.foreach(directory_to_check.strip)do |item|
 			next if item == '.' or item == '..'
 			#filepath = "../data" + "/" + item
 			filepath = directory_to_check + "/" + item
			check_single_file(filepath)
 			#normalised_date = check_single_file(filepath)
 			#returned_values = check_single_file(filepath)
 			#date_in = returned_values[0]
 			#date_out = returned_values[1]
 			#if info_level == "more"
 			#	if date_in != date_out
 			#		outfile.puts("FILE:" + item + " DATE IN:" + date_in.to_s + " DATE OUT:" + date_out.to_s )
 			#	end
 			#else
 			#	if date_in != date_out
 			#		outfile.puts("DATE OUT:" + date_out.to_s )
 		#		end
 		#	end
 		end
 	end

	#we now need to manipulate the data to remove the elements we dont want. do this in a separate method.
	#default output to dlib-migration-tools root dir
	def check_single_file(filepath)
		doc = File.open(filepath){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}
		ns = doc.collect_namespaces # doesnt resolve nested namespaces, this fixes that
		# find max dc version
		nums = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",ns)
		all = nums.to_s
		current = all.rpartition('.').last
		current_dc_version = 'DC.' + current
		#this may get messy.
		#in exams the dept may be under creator OR publisher (a minority)
		#in theses the department will be the publisher - the student is the creator
		#in undergrad papers/projects dept may be in publishe OR creator - but
		# creator may also contain actual student names. Needs some fuzzy logic!
		#populate this then call a dissambiguation script to remove the unwanted
		dept = []
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:publisher/text()",ns).each do |s|
      possible_value = s.to_s
			filter_result = filter_department_values(possible_value)
			if filter_result != "false"
				dept.push(s.to_s)
				puts possible_value +" passed filter"
			end
		end
		#check for the values we wanted (filtering needed)
		#only do this if not present above. not all values of the above will be those we want, so confirm before adding
    #add a "if empty" test TODO
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:creator/text()",ns).each do |s|
			possible_value = s.to_s
			filter_result = filter_department_values(possible_value)
			if filter_result != "false"
				dept.push(s.to_s)
				puts possible_value +" passed filter"
			end
		end
		#dept.each do |d|
			#this is where we will manipulate
		#	return_values = []
		#	puts d.to_s
			#	return return_values
	#	end
	end

  #pattern match and return entire string if found
	#if not found return the string "false"
	def filter_department_values(value)
		#we will need a list of all dc:publishers in the theses/ug papers/exams
		#likewise creators - though this will include individuals
		#start with this for dev. We want to return the whole string of only those
		#strings containing these words
		term_to_filter = value.downcase
		filter_words = ["university","dept","department","school","studies"]
		filter_words.each do |w|
			if term_to_filter.include? w
				return term_to_filter
			end
		end
		#return false if match for term not found in value
		return "false"
	end


	#default action if ruby date_normaliser.rb called from lib folder
	if __FILE__==$0
		d = DepartmentNameNormaliser.new
		puts "please type a department name"
		name = gets
		puts "you typed " + name +" for me"
	end
end
