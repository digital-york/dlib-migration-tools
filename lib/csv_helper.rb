#!/usr/bin/env ruby
require 'nokogiri'
require_relative 'dublin_core_elements_extractor.rb'

class CsvHelper

  def initialize(output_location)
		@output_location = output_location
	end

  def collect_dc_metadata(filename)
    #open a foxml file and pass to ExtractDublinCoreMetadata
    doc = File.open(filename){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}
    dc_metadata_extractor = DublinCoreElementsExtractor.new(doc)
    values_hash = dc_metadata_extractor.extract_key_metadata
    keys = values_hash.keys
    # get value back from hash
    creators = values_hash.fetch(:creators)
    creators.each do |c|
      puts "creator was " + c.to_s
    end
    # pass returned hash to csv creation
    create_csv(values_hash)
  end

  # TODO: elements also need extraction from rels-ext (parent collection membership)
  # also the various content locations - these may not be restricted to EXAM_PAPER
  # and THUMBNAIL_IMAGE
  # Possibly also ACL data to get access permissions

 #This method will create a single csv file from a single foxml file
  def create_csv(dc_hash)
    pid = dc_hash.fetch(:pid)
    outfile_name = pid.sub ':', '_'
    outfile_path = @output_location + "/" + outfile_name + ".csv"
    CSV.open(outfile_path, "wb") do |csv|
      csv_row = get_csv_row(dc_hash)
			csv << csv_row
		end
  end

  def get_csv_row(dc_hash)
    csv_row = []
    dc_hash.each do |key,value|
      item = "#{key}::#{value}" #use :: as separator because pid uses colon, as may parts of some values
      csv_row.push(item)
    end
    return csv_row
  end

=begin
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
		if standard_date == "no match"
			msg = pid + " date error"
			log(msg)
		else
			csv_row.push(standard_date)
		end
		department_names_result.each do |d|
			if d.standard_name == "no value found" or d.standard_name == "not found" or d.standard_name == "needs prior edit" or d.standard_name.length == 0
			    msg = pid + " department name error " + d.standard_name
				log(msg)
			else
				csv_row.push(d.standard_name)
			end
		end
			return csv_row
	end
=end

end
