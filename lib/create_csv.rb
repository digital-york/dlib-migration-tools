#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri'
require 'csv' 
require_relative 'date_normaliser.rb'
require_relative 'department_name_normaliser.rb'

class CreateCsv
	def initialize
		#@csv_list= File.open("firstoutput.txt", "a")
		@outfile = "csv_output.csv"	
	end
	
	def say_hi
		puts "hiya! from CreateCsv"
	end
	
	def migrate_a_file
	    filepath = "../small_data/york_815849.xml"
		date_normaliser = DateNormaliser.new
		department_name_normaliser = DepartmentNameNormaliser.new
		standard_date_result = date_normaliser.check_single_file(filepath)
		standard_date = standard_date_result[1]
		department_names_result = department_name_normaliser.check_single_file(filepath)
	    pid = department_names_result[0].pid
		
		csv_row = []
		csv_row.push(pid)
		csv_row.push(standard_date)
		
		#@csv_list.print("PID:" + pid )
		department_names_result.each do |d|
			#@csv_list.print( " dept:" + d.standard_name  )
			csv_row.push(d.standard_name)
		end
		#@csv_list.print( " DATE:" + standard_date.to_s  )
		CSV.open(@outfile, "wb") do |csv|
			csv << csv_row
		end
	end

	if __FILE__==$0
		cc = CreateCsv.new
		cc.say_hi
	end

end