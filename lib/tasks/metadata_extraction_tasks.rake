namespace :metadata_extraction_tasks do
desc "extract key dublin core metadata elements from foxml files"

# require_relative '../../lib/dublin_core_elements_extractor.rb'
require_relative '../../lib/csv_helper.rb'

  task :greet do
    puts 'greetings from the new dc_metadata_extraction_tasks'
  end

  # rake metadata_extraction_tasks:run_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  task :run_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    ch = CsvHelper.new(args[:output_location])
    ch.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end
end
