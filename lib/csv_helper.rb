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

  # make the datastreams to collect metadata from specifiable
  def collect_metadata(filename, ds_scope)
    ds_to_collect = get_datastream_scope(ds_scope)
    values_hash_array = []
    # open a foxml file and pass to ExtractDublinCoreMetadata
    doc = File.open(filename) { |f| Nokogiri::XML(f, Encoding::UTF_8.to_s) }
    ds_to_collect.each do |ds|
      extractor = extractor_factory(ds, doc)
      values_hash = extractor.extract_key_metadata
      values_hash_array.push(values_hash)
    end
    # pass returned hashes to csv creation
    create_csv(values_hash_array)
  end

  # This method  creates a single csv file from a single foxml file
  # ds_to_include is an array containing a hash of  key:value pairs for each
  # datastream whose key metadata we want to include
  # TODO make append rather than write so will ultimately support batch task
  def create_csv(ds_to_include)
    outfile_name = 'exam_papers_key_metadata'
    outfile_path = @output_location + '/' + outfile_name + '.csv'
    CSV.open(outfile_path, 'wb') do |csv|
      csv_row = get_csv_row(ds_to_include)
      # adds another set of quotes but it appears this is valid
      # https://stackoverflow.com/questions/40166811/writing-to-csv-is-adding-quotes
      csv << csv_row
    end
  end

  # construct a csv row. ds_hashes_to_include is an array containing a hash of
  # key:value pairs for each datastream whose key metadata we want to include
  def get_csv_row(ds_hashes_to_include)
    csv_row = []
    ds_hashes_to_include.each do |ds_hash|
      ds_hash.each do |key, value|
        item = "#{key}:#{value}" # revert to ':' as separator
        csv_row.push(item)
      end
    end
    csv_row
  end

  def extractor_factory(ds_name, doc)
    case ds_name
    when 'dc'
      extractor = DublinCoreElementsExtractor.new(doc)
    when 'rels_ext'
      extractor = RelsExtElementsExtractor.new(doc)
    when 'acl'
      extractor = AclElementsExtractor.new(doc)
    end
    extractor
  end

  def get_datastream_scope(ds_scope)
    case ds_scope
    when 'full'
      ds_to_collect  = %w[dc rels_ext acl]
    when 'dc'
      ds_to_collect  = %w[dc]
    else
      ds_to_collect  = %w[dc]
    end
    ds_to_collect
  end
end
