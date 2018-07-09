namespace :dc_metadata_extraction_tasks do
desc "extract key dublin core metadata elements from foxml files"

require_relative '../../lib/dublin_core_elements_extractor.rb'
require_relative '../../lib/csv_helper.rb'

  task :greet do
    puts "greetings from the new dc_metadata_extraction_tasks"
  end

  #rake dc_metadata_extraction_tasks:run_dc_metadata_collection["../small_data/york_666","/tmp"]
	task :run_dc_metadata_collection, [:foxml_name,:output_location] do |t, args|
		args.with_defaults(:output_location => 'tmp')
		ch = CsvHelper.new(args[:output_location])
    ch.collect_dc_metadata(args[:foxml_name])
	end

end
