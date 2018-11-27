namespace :metadata_extraction_tasks do
desc "extract key dublin core metadata elements from foxml files"

require_relative '../../lib/migration_coordinator.rb'
require_relative '../../lib/record_collectors/pid_identifier.rb'
# require_relative '../../tmp/reformat_pidlist.sh'

  task :greet do
    puts 'greetings from the new dc_metadata_extraction_tasks'
  end

  # this extracts a list of theses pids using curl
  # and is then intended to edit it into the format required by the fedora batch
  # export script. It needs to be run on a machine with appropriate access to the
  # fedora host. pass in username, password, fedora host
  # this is a development task - when complete it will be extended to exams too
  task :get_theses_pids, [:user,:password,:fedorahost] do |t, args|
    p = PidIdentifier.new(args[:user], args[:password],args[:fedorahost])
    p.make_theses_pid_list
    p.remove_unwanted_content
  end

  # rake metadata_extraction_tasks:run_exam_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  task :run_exam_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    c = MigrationCoordinator.new(args[:output_location], 'exam_paper')
    c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end

  # rake metadata_extraction_tasks:run_thesis_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  # at present does exactly the same as for exams - but this will be changed
  task :run_thesis_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    c = MigrationCoordinator.new(args[:output_location], 'thesis')
    c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end
end
