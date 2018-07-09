#!/usr/bin/env ruby
require 'nokogiri'
require_relative 'dublin_core_elements_extractor.rb'

class CsvHelper

  def initialize(output_location)
		@output_location = output_location
	end

  def collect_dc_metadata(filename)
    #open a foxml file and pass to ExtractDublinCoreMetadata
    puts "this will open a foxml file and return a hash of key element names and values"
    #doc = File.open(filename, "a")
      doc = File.open("../small_data/york_666.xml"){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}
    dc_metadata_extractor = DublinCoreElementsExtractor.new
    dc_metadata_extractor.extract_key_metadata(doc)
    #pass returned hash to csv creation
  end

  def create_csv(dc_elements_hash,output_location)
    puts "will make csv"
    #gets called in the collect_dc_metadata method
    #takes hash of dc element name: dc element value pairs
    #and creates csv file at location specified in output_location
  end

end
