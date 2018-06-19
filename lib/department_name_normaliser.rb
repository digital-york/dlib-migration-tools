#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri'
class DepartmentNameNormaliser
	def initialize
	   puts "initialising DateNormaliser"
	end

	def say_hi
	    puts "hi! from department normaliser"
	end

 	def check_folder(folderpath)
 		puts "testing check_folder"
 		#outfile = File.open("corrected_dates_list.txt", "a")
 		directory_to_check = folderpath.strip
 		Dir.foreach(directory_to_check.strip)do |item|
 			next if item == '.' or item == '..'
 			#filepath = "../data" + "/" + item
 			filepath = directory_to_check + "/" + item
			puts "found file " + item
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
			dept.push(s.to_s)
			puts "still checking..."
		end
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:creator/text()",ns).each do |s|
			dept.push(s.to_s)
			puts "still checking..."
		end

		dept.each do |d|
			return_values = []
			puts d.to_s
		#	return return_values
		end
	end


	#default action if ruby date_normaliser.rb called from lib folder
	if __FILE__==$0
		d = DepartmentNameNormaliser.new
		puts "please type a department name"
		name = gets
		puts "you typed " + name +" for me"
	end
end
