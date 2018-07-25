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
    #looking good, now lets think how to add into the csv
    puts "collected " + @headers.size.to_s + "headers"
    Dir.foreach(directory_to_check) do |item|
      next if item == '.' or item == '..'
      filepath= directory_to_check + '/' + item
      collect_metadata(filepath, ds_to_collect)
    end
    csv_header_test   #delete this line!
  end

  def get_headers(directory_to_check, ds_to_collect)
    Dir.foreach(directory_to_check) do |item|
      next if item == '.' or item == '..'
      filepath= directory_to_check + '/' + item
      doc = File.open(filepath) { |f| Nokogiri::XML(f, Encoding::UTF_8.to_s) }
      ds_to_collect.each do |ds|
        extractor = extractor_factory(ds, doc)
        headers = extractor.collect_headers
        headers.each do |h|
          unless @headers.include?(h.to_s)
            @headers.push(h.to_s)
          end
        end
      end
    end
  end

    #delete this method
    def csv_header_test
     outfile_path = @output_location + '/headertest.csv'
      puts "output path was " + outfile_path
     headers = @unique_keys_to_use_as_headers
     CSV.open(outfile_path, 'a+',) do |csv|
       csv << headers if csv.count.eql? 0
       csv_row = CSV::Row.new(headers, [])
       headers.each do |h|
         puts 'h was ' + h
         headername = h.to_s
         csv_row["pid"] = "woopsy"
         csv_row["title"] = "smell"
         csv_row["creator2"] = "terrible"
         csv_row[headername] = "yikes"
      end
       csv << csv_row
     end
   end

   def get_column_headers(ds_hashes_array)
     #try getting all the keys
     ds_hashes_array.each do |ds_hash|
       ds_hash.each do
         keys = ds_hash.keys
         keys.each do |k|
           unless @unique_keys_to_use_as_headers.include?(k.to_s)
           @unique_keys_to_use_as_headers.push(k.to_s)
         end
       end
       end
       end
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
    get_column_headers(values_hash_array) #delete me
  end

  # This method  creates a single csv file from a single foxml file
  # ds_to_include is an array containing a hash of  key:value pairs for each
  # datastream whose key metadata we want to include
  def create_csv(ds_to_include)
    outfile_name = 'exam_papers_key_metadata'
    outfile_path = @output_location + '/' + outfile_name + '.csv'
    CSV.open(outfile_path, 'a+') do |csv|
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
    when 'content_location'
      extractor = ContentLocationExtractor.new(doc)
    end
    extractor
  end

  def get_datastream_scope(ds_scope)
    case ds_scope
    when 'full'
      ds_to_collect  = %w[dc rels_ext acl content_location]
      #ds_to_collect  = %w[dc rels_ext acl]
    when 'dc'
      ds_to_collect  = %w[dc]
    else
      ds_to_collect  = %w[dc]
    end
    ds_to_collect
  end
end
