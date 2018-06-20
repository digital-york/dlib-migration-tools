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
		unique_dept = []
		unique_initial_values = [] #for debug
 		directory_to_check = folderpath.strip
 		Dir.foreach(directory_to_check.strip)do |item|
 			next if item == '.' or item == '..'
 			#filepath = "../data" + "/" + item
 			filepath = directory_to_check + "/" + item
			check_single_file(filepath, unique_dept, unique_initial_values)
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
		puts "size of unique_dept " + unique_dept.size.to_s
		outfile = File.open("unique_department_names.txt", "a")
		unique_dept.each do |d|
			outfile.puts(d.to_s)
		end

		outfile2 = File.open("unique_initial_values.txt", "a")
		unique_initial_values.each do |d|
			outfile2.puts(d.to_s)
		end
 	end

	#we now need to manipulate the data to remove the elements we dont want. do this in a separate method.
	#default output to dlib-migration-tools root dir
	def check_single_file(filepath, unique_dept, unique_initial_values)
		doc = File.open(filepath){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}
		ns = doc.collect_namespaces # doesnt resolve nested namespaces, this fixes that
		# find max dc version
		nums = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",ns)
		all = nums.to_s
		current = all.rpartition('.').last
		current_dc_version = 'DC.' + current
		#in exams the dept may be under creator OR publisher (a minority)
		#in theses the department will be the publisher - the student is the creator
		#in undergrad papers/projects dept may be in publishe OR creator - but
		# creator may also contain actual student names.
		dept = []
		#look in creators first
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:creator/text()",ns).each do |s|
      possible_value = s.to_s
			if unique_initial_values.include? (possible_value)
			 #do nothing
		 	else
			 unique_initial_values.push(possible_value)
		 	end
			filter_result = filter_department_values(possible_value)
			if filter_result != "false"
				dept.push(s.to_s)
				puts "dc:publisher 	" + possible_value
			end
		end
		#didnt find a value looking like a department or institution in publisher, so check publishers
		if dept.size < 1
			doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:publisher/text()",ns).each do |s|
				possible_value = s.to_s
				if unique_initial_values.include? (possible_value)
				 #do nothing
			 	else
				 unique_initial_values.push(possible_value)
			 	end
				filter_result = filter_department_values(possible_value)
				if filter_result != "false"
					dept.push(s.to_s)
					puts "dc:creator 	" + possible_value
				end
			end
		end
		# list all unique dept values found for debugging
		dept.each do |d|
		 d = d.to_s
			if unique_dept.include? (d)
			 #do nothing
		 	else
			 unique_dept.push(d)
		 	end
		end
	end

  #pattern match and return entire string if found, excluding individual names
	#if not found return the string "false"
	#this just extracts the value of the initial string - not yet stanardised
	def filter_department_values(value)
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
