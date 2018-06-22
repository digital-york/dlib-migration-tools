#!/usr/bin/env ruby
# encoding: UTF-8
require 'nokogiri' 

#this should pull together the various data handling scripts to create a single csv file 
class MigrateFoxmlToCsv

	def initialize
		puts "initialising DateNormaliser"
	end

	def say_hi
		puts "howdy! from MigrateFoxmlToCsv"
	end


#default action if ruby date_normaliser.rb called from lib folder
	if __FILE__==$0
		d = MigrateFoxmlToCsv.new
		d.say_hi
	end

end