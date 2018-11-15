#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require_relative 'extractors/dublin_core_elements_extractor.rb'
require_relative 'extractors/rels_ext_elements_extractor.rb'
require_relative 'extractors/acl_elements_extractor.rb'
require_relative 'extractors/content_location_extractor.rb'
require_relative 'normalisers/metadata_normaliser.rb' # possible
# coordinate the collection of metadata, any normalisation, + creation of csv
class MigrationCoordinator
  def initialize(output_location)
    @output_location = output_location
    @unique_keys_to_use_as_headers = []
    @column_headers = []
    @headers = []
  end

  # batch csv extraction from a single flat folder containing foxml files only
  # command line call syntax: rake metadata_extraction_tasks:
  # run_<exam_paper|thesis>_metadata_collection_for _folder[<"/path/to/folder">
  # <full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  def collect_metadata_for_whole_folder(folderpath, ds_scope, record_type)
    ds_to_collect = get_datastream_scope(ds_scope.strip)
    directory_to_check = folderpath.strip
    # collect, headers first, as we need a complete list of columns in advance
    get_headers(directory_to_check, ds_to_collect)
    @headers = reorder_headers
    Dir.foreach(directory_to_check) do |item|
      next if item == '.' || item == '..'
      filepath = directory_to_check + '/' + item
      collect_metadata(filepath, ds_to_collect, record_type)
    end
  end

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
          # only push header arrays with non zero content
          if h.size > 0
            @headers.push(h.to_s)
          end
        end
      end
    end
  end

  # headers are added to the initial array in the order in which the elements
  # they refer to  are encountered in the records. So at this point multiple
  # values may not appear in sequence. This reorders them, for readibility. do
  # this way rather than using alphabetical sort as allows more logical ordering
  def reorder_headers
    ordered_array = %w[pid title date rights_holder rights_link rights_statement]
    creators, publishers, qualification_names, modules,
    descriptions, subjects, contributors = Array.new(7) { [] } # create arrays for all these
    # for multivalued elements
    @headers.each do |t|
      if t.start_with? 'creator'
        creators.push(t)
      elsif t.start_with? 'publisher'
        publishers.push(t)
      elsif t.start_with? 'subject'
        subjects.push(t)
      elsif t.start_with? 'qualification_name'
        qualification_names.push(t)
      elsif t.start_with? 'module'
        modules.push(t)
      elsif t.start_with? 'description'
        descriptions.push(t)
      elsif t.start_with? 'contributor'
        contributors.push(t)
      else
        unless ordered_array.any? { |s| t.include? s }
          puts 'unexpected header! t was ' + t.to_s
        end
      end
    end
    header_arrays = [creators, publishers, subjects, qualification_names,
                     modules, descriptions, contributors]
    header_arrays.each do |h|
      h.each do |each_header_name|
        ordered_array.push(each_header_name)
      end
    end
    ordered_array
  end

  # make the datastreams to collect metadata from specifiable
  def collect_metadata(filename, ds_to_collect, record_type)
    values_hash_array = []
    normaliser = MetadataNormaliser.new(record_type)
    # open a foxml file and pass to ExtractDublinCoreMetadata
    doc = File.open(filename) { |f| Nokogiri::XML(f, Encoding::UTF_8.to_s) }
    ds_to_collect.each do |ds|
      extractor = extractor_factory(ds, doc)
      values_hash = extractor.extract_key_metadata
      # do any normalisation of  metadata values before adding to main array
      normaliser.normalise_metadata(values_hash)
      values_hash_array.push(values_hash)
    end
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
        key = key.to_s.downcase
        csv_row[key.to_s] = value
      end
    end
    csv_row
  end

  def extractor_factory(ds_name, doc)
    case ds_name
    when 'dc'
      DublinCoreElementsExtractor.new(doc)
    when 'rels_ext'
      RelsExtElementsExtractor.new(doc)
    when 'acl'
      AclElementsExtractor.new(doc)
    when 'content_location'
      ContentLocationExtractor.new(doc)
    end
  end

  def get_datastream_scope(ds_scope)
    case ds_scope
    when 'full'
      %w[dc rels_ext acl content_location]
    when 'dc'
      %w[dc]
    when 'dc_plus_content_location'
      %w[dc content_location]
    when 'dc_plus_acl'
      %w[dc acl]
    when 'dc_plus_rels_ext'
      %w[dc rels_ext]
    else
      %w[dc]
    end
  end

end
