#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri'
class DepartmentNameNormaliser



	def initialize
	    @unique_initial_values = []
		@unique_dept = []
		@logfile = File.open("tmp/department_edits.log", "a")
		@filtered_name_list = File.open("tmp/unique_department_names.txt", "a")
		@unfiltered_name_list= File.open("tmp/unique_initial_values.txt", "a")
	end

	def say_hi
	    puts "hi! from department normaliser"
	end


	def check_folder(folderpath,info_level)
 		directory_to_check = folderpath.strip
 		Dir.foreach(directory_to_check.strip)do |item|
 			next if item == '.' or item == '..'
				puts "hard at work..."
				filepath = directory_to_check + "/" + item
				return_value_set = check_single_file(filepath)
				return_value_set.each do |rv|
					#'more' gives extended details where no standard department found, 'show_all' logs all details for all returns, otherwise just give message where no standard department found
					department_details = rv
						pid = department_details.pid
						initial_values = department_details.initial_name
						standardised_value = department_details.standard_name
					if info_level == "more"
						if standardised_value == "no value found" or standardised_value == "not found" or standardised_value == "needs prior edit"
							@logfile.puts("PID:" + pid + " VALUE IN:" + initial_values + " VALUE OUT:" + standardised_value )
						end
					elsif info_level == "show_all"
							@logfile.puts("PID:" + pid + " VALUE IN:" + initial_values + " VALUE OUT:" + standardised_value )
					else
						if standardised_value == "no value found" or standardised_value == "not found" or standardised_value == "needs prior edit"
							@logfile.puts(" VALUE OUT:" + standardised_value)
						end
					end
				end
			end

			#make text files
			@unique_dept.each do |d|
				@filtered_name_list.puts(d.to_s)
			end

			@unique_initial_values.each do |iv|
				@unfiltered_name_list.puts(iv.to_s)
			end
 	end

	#we now need to manipulate the data to remove the elements we dont want. do this in a separate method.
	#default output to dlib-migration-tools root dir
	#think at this point this is ok for multiples ?
	def check_single_file(filepath)
		return_values = []  #one or more sets of values from a single file
		doc = File.open(filepath){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}
		ns = doc.collect_namespaces # doesnt resolve nested namespaces, this fixes that
		pid = doc.xpath("//foxml:digitalObject/@PID",ns).to_s
		# find max dc version
		nums = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",ns)
		all = nums.to_s
		current = all.rpartition('.').last
		current_dc_version = 'DC.' + current
		#in exams the dept may be under creator OR publisher (a minority) In theses the department will be the publisher - the student is the creator
		#in undergrad papers/projects dept may be in publishe OR creator - but  creator may also contain actual student names.
		initial_dept_names = []
		initial_values = []

		#check creators first
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:creator/text()",ns).each do |s|
		    possible_value = s.to_s
			initial_values.push(possible_value)
			filter_result = filter_department_values(possible_value)
			if filter_result != "false"
				initial_dept_names.push(filter_result.to_s)
			end
		end
		#didnt find a value looking like a department or institution in creators, so check publishers
		if initial_dept_names.size < 1
			doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:publisher/text()",ns).each do |s|
				possible_value = s.to_s
				initial_values.push(possible_value)
				filter_result = filter_department_values(possible_value)
				if filter_result != "false"
					initial_dept_names.push(filter_result.to_s)
				end
			end
		end
		#now replace original value with the standard name (pref_label)
		#departments may be multiple in case of modular courses
		#dept_details = DepartmentDetails.new
		if initial_dept_names.size == 0
			dept_details = DepartmentDetails.new
			dept_details = DepartmentDetails.new
			dept_details.pid = pid
			dept_details.initial_name = "none found"
			dept_details.standard_name = "no value found"
			return_values.push(dept_details)
		end

		initial_dept_names.each do |initial_dept|
			dept_details = DepartmentDetails.new
			initial_dept = initial_dept.to_s
			standardised_name = get_standard_department_name(initial_dept)
			dept_details.pid = pid
			dept_details.initial_name = initial_dept
			dept_details.standard_name = standardised_name
			return_values.push(dept_details)
		end


		# list all unique initial values found for debugging
		initial_values.each do |v|
		unless @unique_initial_values.include? (v)
			 	@unique_initial_values.push(v)
		 	end
		end
		# list all unique dept values found for debugging
		initial_dept_names.each do |d|
			d = d.to_s
			unless @unique_dept.include? (d)
			 	@unique_dept.push(d)
		 	end
		end
		#return return_values
		return return_values
	end

	#pattern match and return entire string if found, excluding individual names
	#if not found return the string "false"
	#this just extracts the value of the initial string - not yet stanardised
	def filter_department_values(value)
		term_to_filter = value.downcase
		#include those values which are not student names but may need handling
		filter_words = ["university","dept","department","school","studies","language","unit","edexcel","education","aqa","ocr","zigzag education"]
		filter_words.each do |w|
			if term_to_filter.include? w
				return term_to_filter
			end
		end
		#return false if match for term not found in value
		return "false"
	end

	#pattern match and return the correct standard pref_label for a department
	#this is horrible and wordy but cant at present see an alternative
	#order is important in some cases - but otherwise try to order alphabetically
	def get_standard_department_name(string_to_match)
		standard_name = ""
		string_to_match = string_to_match.downcase  #get rid of case inconsistencies
		if string_to_match.include? "reconstruction"
			standard_name = "University of York. Post-war Reconstruction and Development Unit"
		elsif string_to_match.include? "applied human rights" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Applied Human Rights"
		elsif string_to_match.include? "health economics" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Health Economics"
		elsif string_to_match.include? "lifelong learning" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Lifelong Learning"
		elsif string_to_match.include? "medieval studies" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Medieval Studies"
		elsif string_to_match.include? "renaissance" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Renaissance and Early Modern Studies"
		elsif string_to_match.include? "reviews" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Reviews and Disseminations"
		elsif string_to_match.include? "women" #at top so looks for single subjects later
			standard_name = "University of York. Centre for Women's Studies"
		elsif string_to_match.include? "languages for all"
			standard_name = "University of York. Languages for All"
		elsif string_to_match.include? "school of social and political science"#at top so looks for single subjects later
	    	standard_name = "University of York. School of Social and Political Science"
		elsif string_to_match.include? "school of politics economics and philosophy" #at top so looks for single subjects later
	    	standard_name = "University of York. School of Politics Economics and Philosophy"
		elsif string_to_match.include? "economics and related" #at top so looks for single subjects later
	    	standard_name =  "University of York. Department of Economics and Related Studies"
		elsif string_to_match.include? "economics and philosophy" #at top so looks for single subjects later
			standard_name = "University of York. School of Politics Economics and Philosophy"
		elsif string_to_match.include? "departments of english and history of art"
			#two departments squeezed into one! MUST precede history of art. but just one such record
			standard_name = "needs prior edit"
	    	#standard_name =  "University of York. Department of English and Related Literature"
			#standard_name =  "University of York. Department of History of Art"
		elsif string_to_match.include? "history of art" #at top so looks for history later. but below english and history of art!
	    	standard_name = "University of York. Department of History of Art"
		elsif string_to_match.include? "electronic"
			standard_name = "University of York. Department of Electronic Engineering"
		elsif string_to_match.include? "theatre"
			standard_name = "University of York. Department of Theatre, Film and Television"
		elsif string_to_match.include? "physics"
			standard_name = "University of York. Department of Physics"
		elsif string_to_match.include? "computer"
			standard_name = "University of York. Department of Computer Science"
		elsif string_to_match.include? "psychology"
			standard_name = "University of York. Department of Psychology"
		elsif string_to_match.include? "law"
			standard_name = "University of York. York Law School"
		elsif string_to_match.include? "mathematics"
			standard_name = "University of York. Department of Mathematics"
		elsif string_to_match.include? "advanced architectural"
	    	standard_name = "University of York. Institute of Advanced Architectural Studies"
		elsif string_to_match.include? "conservation"
	    	standard_name = "University of York. Centre for Conservation Studies"
		elsif string_to_match.include? "eighteenth century"
	    	standard_name = "University of York. Centre for Eighteenth Century Studies"
		elsif string_to_match.include? "chemistry"
	    	standard_name = "University of York. Department of Chemistry"
		elsif string_to_match.include? "history"   #ok because of order
	    	standard_name = "University of York. Department of History"
		elsif string_to_match.include? "sociology"
	    	standard_name =  "University of York. Department of Sociology"
		elsif string_to_match.include? "education"
	    	standard_name = "University of York. Department of Education"
		elsif string_to_match.include? "music"
	    	standard_name =  "University of York. Department of Music"
		elsif string_to_match.include? "archaeology"
	    	standard_name =  "University of York. Department of Archaeology"
		elsif string_to_match.include? "biology"
	    	standard_name =  "University of York. Department of Biology"
		elsif string_to_match.include? "biochemistry" or string_to_match.include? "ocr" or string_to_match.include? "aqa" or string_to_match.include? "edexcel"
	    	standard_name =  "University of York. Department of Biology" #confirmed with metadata team
		elsif string_to_match.include? "english and related"
	    	standard_name =  "University of York. Department of English and Related Literature"
		elsif string_to_match.include? "health sciences"
	    	standard_name =  "University of York. Department of Health Sciences"
		elsif string_to_match.include? "politics"
	    	standard_name = "University of York. Department of Politics"
		elsif string_to_match.include? "philosophy"
	    	standard_name =  "University of York. Department of Philosophy"
		elsif string_to_match.include? "social policy"
	    	standard_name =  "University of York. Department of Social Policy and Social Work"
		elsif string_to_match.include? "management"
	    	standard_name =  "University of York. The York Management School"
		elsif string_to_match.include? "language and linguistic science"
	    	standard_name = "University of York. Department of Language and Linguistic Science"
		elsif string_to_match.include? "hull"
	    	standard_name = "Hull York Medical School"
		elsif string_to_match.include? "international pathway"
	    	standard_name = "University of York. International Pathway College"
		elsif string_to_match.include? "school of criminology"
	    	standard_name = "University of York. School of Criminology"
		elsif string_to_match.include? "natural sciences"
	    	standard_name = "University of York. School of Natural Sciences"
		elsif string_to_match.include? "environment"
	    	standard_name = "University of York. Environment Department"
		else
			standard_name = "not found"
		end
	end

	#use this as more readable way to create  multivalued department information
	class DepartmentDetails
		attr_accessor :pid, :initial_name, :standard_name
		def initialize
			pid = ""
			initial_name = ""
			standard_name = ""
		end


	end


	#default action if ruby date_normaliser.rb called from lib folder
	if __FILE__==$0
		d = DepartmentNameNormaliser.new
		puts "please type a department name"
		name = gets
		label = d.get_standard_department_name(name)
		puts "standardised to " + label
	end
end
