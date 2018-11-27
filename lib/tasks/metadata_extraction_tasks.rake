namespace :metadata_extraction_tasks do
desc "extract key dublin core metadata elements from foxml files"

require_relative '../../lib/migration_coordinator.rb'
require_relative '../../lib/record_collectors/pid_identifier.rb'

  task :greet do
    puts 'greetings from the new dc_metadata_extraction_tasks'
    sh "ls"
  end

  # this extracts a list of theses pids using curl
  # and is then intended to edit it into the format required by the fedora batch
  # export script. It needs to be run on a machine with appropriate access to the fedoa host
  # would need to pass in username and password
  # then rewrite curl_theses_query.sh to take these as parameters
  task :get_theses_pids, [:user,:password,:fedorahost] do |t, args|
    puts args[:user]
    puts args[:password]
    puts args[:fedorahost]
    p = PidIdentifier.new(args[:user], args[:password],args[:fedorahost])
    p.get_pid_list
    # TODO now add the reformatting which is currrently being done using cut.
    # something like this from correct dir
    # sh reformat_pidlist.sh
    # this should result in a pidlist in the correct format
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
