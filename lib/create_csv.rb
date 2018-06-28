#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri'
require 'csv' 
require_relative 'date_normaliser.rb'
require_relative 'department_name_normaliser.rb'

class CreateCsv
	def initialize
		@outfile = "csv_output.csv"	
	end
	
	def say_hi
		puts "hiya! from CreateCsv"
	end	
	
	
	def make_csv_from_batch(folderpath)
		directory_to_check = folderpath.strip
		csv_rows = []
 		Dir.foreach(directory_to_check.strip)do |item|
			next if item == '.' or item == '..'
				current_row = get_csv_row(directory_to_check + "/" + item)
				csv_rows.push(current_row)
		end
		CSV.open(@outfile, "wb") do |csv|
			csv_rows.each do |row|
				csv << row
			end
		end
		
	end
	
	def make_csv_from_single_file(filepath)
		filepath = filepath.strip
		file_row = get_csv_row(filepath)
		CSV.open(@outfile, "wb") do |csv|
			csv << file_row
		end
	end
	
	#return the array of values for a single file to insert into csv
	def get_csv_row(filepath)
		filepath = filepath.strip
		date_normaliser = DateNormaliser.new
		department_name_normaliser = DepartmentNameNormaliser.new
		standard_date_result = date_normaliser.check_single_file(filepath)
		standard_date = standard_date_result[1]
		department_names_result = department_name_normaliser.check_single_file(filepath)
	    pid = department_names_result[0].pid
		
		csv_row = []
		csv_row.push(pid)
		csv_row.push(standard_date)
		department_names_result.each do |d|
			csv_row.push(d.standard_name)
		end
			return csv_row
	end	
	

	if __FILE__==$0
		cc = CreateCsv.new
		cc.say_hi
	end

end