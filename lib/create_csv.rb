#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri'
require 'csv' 
require_relative 'date_normaliser.rb'
require_relative 'department_name_normaliser.rb'

class CreateCsv
	def initialize
		puts "initialising CreateCsv"
		@csv_list= File.open("some namebeforeIgo.txt", "a")		
	end
	
	def say_hi
		puts "hiya! from CreateCsv"
	end
	
	def migrate_a_file
	    filepath = "../small_data/york_815848.xml"
		date_normaliser = DateNormaliser.new
		department_name_normaliser = DepartmentNameNormaliser.new
		department_names_result = department_name_normaliser.check_single_file(filepath)
		pid = department_names_result[0].pid #this will be the same for all members of result set for a single file
		standard_date = date_normaliser.check_single_file(filepath)	
		department_names_result.each do |d|
			@csv_list.puts("PID:" + pid + " dept:" + d.standard_name  )
		end
		@csv_list.puts( " DATE:" + standard_date.to_s  )
	end

	if __FILE__==$0
		d = MigrateFoxml.new
		d.say_hi
	end

end