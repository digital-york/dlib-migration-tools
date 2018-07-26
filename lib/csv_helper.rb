#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require_relative 'dublin_core_elements_extractor.rb'
require_relative 'rels_ext_elements_extractor.rb'
require_relative 'acl_elements_extractor.rb'
require_relative 'content_location_extractor.rb'
# coordinate the collection of metadata + creation of csv
class CsvHelper
  def initialize(output_location)
    @output_location = output_location
    @unique_keys_to_use_as_headers = []
    @column_headers = []
    @headers = []
  end

  # batch csv extraction from a single flat folder containing foxml files only
  def collect_metadata_for_whole_folder(folderpath, ds_scope)
    ds_to_collect = get_datastream_scope(ds_scope.strip)
    directory_to_check = folderpath.strip
    # collect, headers first, as we need a complete list of columns in advance
    get_headers(directory_to_check, ds_to_collect)
    Dir.foreach(directory_to_check) do |item|
      next if item == '.' || item == '..'
      filepath = directory_to_check + '/' + item
      collect_metadata(filepath, ds_to_collect)
    end
  end
# TODO:  content locations
  def get_headers(directory_to_check, ds_to_collect)
    Dir.foreach(directory_to_check) do |item|
    next if item == '.' || item == '..'
      filepath = directory_to_check + '/' + item
      doc = File.open(filepath) { |f| Nokogiri::XML(f, Encoding::UTF_8.to_s) }
      ds_to_collect.each do |ds|
        extractor = extractor_factory(ds, doc)
        new_headers = extractor.collect_headers
        new_headers.each do |h|
          next if @headers.include?(h.to_s)
          @headers.push(h.to_s)
        end
      end
    end
  end

  # make the datastreams to collect metadata from specifiable
  def collect_metadata(filename, ds_to_collect)
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
  def create_csv(ds_to_include)
    outfile_name = 'exam_papers_key_metadata'
    outfile_path = @output_location + '/' + outfile_name + '.csv'
    CSV.open(outfile_path, 'a+') do |csv|
      csv << @headers if csv.count.eql? 0
      csv_row = get_csv_row(ds_to_include)
      csv << csv_row
    end
  end

  # construct a csv row. ds_hashes_to_include is an array containing a hash of
  # key:value pairs for each datastream whose key metadata we want to include
  def get_csv_row(ds_hashes_to_include)
    csv_row = CSV::Row.new(@headers, [])
    ds_hashes_to_include.each do |ds_hash|
      ds_hash.each do |key, value|
        csv_row[key.to_s] = value
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
    when 'content_location'
      extractor = ContentLocationExtractor.new(doc)
    end
    extractor
  end

  def get_datastream_scope(ds_scope)
    case ds_scope
    when 'full'
      ds_to_collect  = %w[dc rels_ext acl content_location]
    when 'dc'
      ds_to_collect  = %w[dc]
    when 'dc_plus'
      ds_to_collect  = %w[dc rels_ext acl content_location]
    else
      ds_to_collect  = %w[dc]
    end
    ds_to_collect
  end
end
