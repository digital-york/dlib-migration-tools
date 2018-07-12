#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require_relative 'dublin_core_elements_extractor.rb'
require_relative 'rels_ext_elements_extractor.rb'
require_relative 'acl_elements_extractor.rb'
# coordinate the collection of metadata + creation of csv
class CsvHelper
  def initialize(output_location)
    @output_location = output_location
  end

  def collect_metadata(filename)
    # open a foxml file and pass to ExtractDublinCoreMetadata
    doc = File.open(filename) { |f| Nokogiri::XML(f, Encoding::UTF_8.to_s) }
    dc_metadata_extractor = DublinCoreElementsExtractor.new(doc)
    dc_values_hash = dc_metadata_extractor.extract_key_metadata
    create_csv(dc_values_hash)
  end

  def collect_full_metadata(filename)
    # open a foxml file and pass to ExtractDublinCoreMetadata
    doc = File.open(filename) { |f| Nokogiri::XML(f, Encoding::UTF_8.to_s) }
    dc_metadata_extractor = DublinCoreElementsExtractor.new(doc)
    dc_values_hash = dc_metadata_extractor.extract_key_metadata
    rels_ext_metadata_extractor = RelsExtElementsExtractor.new(doc)
    rels_ext_values_hash = rels_ext_metadata_extractor.extract_key_metadata
    acl_metadata_extractor = AclElementsExtractor.new(doc)
    acl_hash = acl_metadata_extractor.extract_key_metadata
    # pass returned hash to csv creation
    create_csv_full(dc_values_hash, rels_ext_values_hash, acl_hash)
  end

  # TODO: elements also need extraction from rels-ext (parent collection )
  # also various content locations - may not be just EXAM_PAPER
  # and THUMBNAIL_IMAGE
  # Possibly also ACL data to get access permissions

  # This method will create a single csv file from a single foxml file
  def create_csv_full(dc_hash, rels_ext_hash, acl_hash)
    pid = dc_hash.fetch(:pid)
    outfile_name = pid.sub ':', '_'
    outfile_path = @output_location + '/' + outfile_name + '.csv'
    CSV.open(outfile_path, 'wb') do |csv|
      csv_row = get_csv_row_full(dc_hash, rels_ext_hash, acl_hash)
      # adds another set of quotes but it appears this is valid
      # https://stackoverflow.com/questions/40166811/writing-to-csv-is-adding-quotes
      csv << csv_row
    end
  end

  # This method will create a single csv file from a single foxml file
  def create_csv(dc_hash)
    pid = dc_hash.fetch(:pid)
    outfile_name = pid.sub ':', '_'
    outfile_path = @output_location + '/' + outfile_name + '.csv'
    CSV.open(outfile_path, 'wb') do |csv|
      csv_row = get_csv_row(dc_hash)
      # adds another set of quotes but it appears this is valid
      # https://stackoverflow.com/questions/40166811/writing-to-csv-is-adding-quotes
      csv << csv_row
    end
  end

  def get_csv_row(dc_hash)
    csv_row = []
    dc_hash.each do |key, value|
      # use :: as separator - pid uses colon, as may parts of some values
      item = "#{key}::#{value}"
      # adds another set of quotes but it appears this is valid
      # https://stackoverflow.com/questions/40166811/writing-to-csv-is-adding-quotes
      csv_row.push(item)
    end
    return csv_row # lint lies! not redundant! doesnt return csv_row without it!
  end

  def get_csv_row_full(dc_hash, rels_ext_hash, acl_hash)
    csv_row = []
    dc_hash.each do |key, value|
      # use :: as separator - pid uses colon, as may parts of some values
      item = "#{key}::#{value}"
      csv_row.push(item)
    end
    rels_ext_hash.each do |key, value|
      item = "#{key}::#{value}"
      csv_row.push(item)
    end
    acl_hash.each do |key, value|
      item = "#{key}::#{value}"
      csv_row.push(item)
    end
    return csv_row
  end
end
