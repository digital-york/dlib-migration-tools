namespace :metadata_extraction_tasks do
desc "extract key dublin core metadata elements from foxml files"

require_relative '../../lib/migration_coordinator.rb'

  task :greet do
    puts 'greetings from the new dc_metadata_extraction_tasks'
  end

  # rake metadata_extraction_tasks:run_exam_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  task :run_exam_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    c = MigrationCoordinator.new(args[:output_location])
    c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end

  # rake metadata_extraction_tasks:run_thesis_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  # at present does exactly the same as for exams - but this will be changed
  task :run_thesis_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    c = MigrationCoordinator.new(args[:output_location])
    c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end
end
