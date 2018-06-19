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


	#default action if ruby date_normaliser.rb called from lib folder
	if __FILE__==$0
		d = DepartmentNameNormaliser.new
		puts "please type a department name"
		name = gets
		d.test_normalisation(name)
	end
end
