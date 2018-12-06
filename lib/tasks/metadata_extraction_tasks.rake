namespace :metadata_extraction_tasks do
desc "extract key dublin core metadata elements from foxml files"

require_relative '../../lib/migration_coordinator.rb'
require_relative '../../lib/record_collectors/pid_identifier.rb'
require_relative '../../lib/record_collectors/exporter.rb'

  task :greet do
    puts 'greetings, earthlings '
  end

  # this extracts a list of theses pids using curl
  # and edits it into the format required by the fedora batch
  # export script. It needs to be run on a machine with appropriate access to the
  # fedora host. pass in username, password, fedora host
  # this is a development task - when complete it will be extended to exams too
    task :get_theses_pids, [:fed_user,:fed_password,:fedorahost,:digilib_pwd] do |t, args|
    p = PidIdentifier.new(args[:fed_user], args[:fed_password], args[:fedorahost])
    p.make_theses_pid_list
    p.remove_unwanted_content
    p.upload_to_fedora_host(args[:digilib_pwd])
  end

  # rake metadata_extraction_tasks:export_records
  # [<host>, <digilib_password>, <fedora_pasword>, <pid_file_to_use>, <path_to_export_dir>, <dir to export to>]
  task :export_records, [:host, :digilibpassword, :fedpassword, :pidfile, :export_dir, :to_dir] do |t, args|
    e = Exporter.new
    e.export_foxml(args[:host], args[:digilibpassword], args[:fedpassword], args[:pidfile], args[:export_dir], args[:to_dir])
  end

  # rake metadata_extraction_tasks:run_thesis_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  # at present does exactly the same as for exams - but this will be changed
  task :run_thesis_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    c = MigrationCoordinator.new(args[:output_location], 'thesis')
    c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end

  # rake metadata_extraction_tasks:run_exam_metadata_collection_for_folder
  # [<"/path/to/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
  task :run_exam_metadata_collection_for_folder, [:path_to_folder,:scope,:output_location] do |t, args|
    args.with_defaults(:output_location => 'tmp')
    c = MigrationCoordinator.new(args[:output_location], 'exam_paper')
    c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
  end

  # the aim of this task is to run an extraction end to end, starting with
  # identifying the correct records, exporting them from the existing fedora 3
  # repository and then outputting metadata as normalised csv
  #the script runs interactively 
  task :do_all_extraction_tasks do
    STDOUT.puts "ENTER FEDORA USER:"
    f_user = STDIN.gets.strip
    STDOUT.puts "ENTER FEDORA PASSWORD"
    f_pwd = STDIN.gets.strip
    STDOUT.puts "ENTER FEDORA HOST"
    host = STDIN.gets.strip
    STDOUT.puts "ENTER DIGILIB PASSWORD"
    dlib_pwd = STDIN.gets.strip
    # string tasks together by simply listing
    Rake::Task["metadata_extraction_tasks:get_theses_pids"].invoke(f_user, f_pwd, host, dlib_pwd)
    puts "collected list of pids for theses now in place on remote fedora client "
  end
end
