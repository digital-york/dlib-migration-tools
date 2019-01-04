namespace :metadata_extraction_tasks do
desc 'extract key dublin core metadata elements from foxml files'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require_relative '../../lib/migration_coordinator.rb'
require_relative '../../lib/record_collectors/pid_identifier.rb'
require_relative '../../lib/record_collectors/exporter.rb'

    desc 'quick test to confirm rake is working.'
    task :greet do
      puts 'greetings, earthlings'
    end

    # extract a list of  pids using curl
    # and edit it into the format required by the fedora batch
    # export script. Must be run on a machine with appropriate access to
    # the fedora host. Params:  fedoraAdmin password, host, name (without
    # file extension) of pid file to be created), digilib password, record type'
    desc 'make pidfile (list of record identifiers).'
    task :get_pids, [:fed_password,:host,:pidfile_name,:digilib_pwd,:record_type] do |t, args|
      p = PidIdentifier.new(args[:fed_password], args[:host],args[:pidfile_name],args[:digilib_pwd])
      p.provide_pidlist(args[:record_type])
    end

    # rake metadata_extraction_tasks:export_records
    # [<host>, <digilib_password>, <fedora_pasword>,
    # <pid_file_to_use, no file extension>,<dir on local box to export to>]
    desc 'export records listed in pidfile from fedora3 repo'
    task :export_records, [:host,:digilibpassword,:fedpassword,:pidfile,:to_dir] do |t, args|
      e = Exporter.new
      e.export_foxml(args[:host], args[:digilibpassword], args[:fedpassword], args[:pidfile], args[:to_dir])
    end

    # rake metadata_extraction_tasks:collect_thesis_metadata_from_folder
    # [<"path/to/exported/foxml/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
    desc 'extract theses metadata from foxml records to csv file'
    task :collect_thesis_metadata_from_folder, [:path_to_foxml_folder,:scope,:output_location] do |t, args|
      args.with_defaults(:output_location => 'tmp')
      c = MigrationCoordinator.new(args[:output_location], 'thesis')
      c.collect_metadata_for_whole_folder(args[:path_to_foxml_folder], args[:scope])
    end

    # rake metadata_extraction_tasks:collect_exam_metadata_collection_from_folder
    # [<"/path/to/exported/foxml/folder">,<full|dc|dc_plus_content_location>,<"/path_to_output_location">]
    desc 'extract exam metadata from foxml records to csv file'
    task :collect_exam_metadata_from_folder, [:path_to_folder,:scope,:output_location] do |t, args|
      args.with_defaults(:output_location => 'tmp')
      c = MigrationCoordinator.new(args[:output_location], 'exam_paper')
      c.collect_metadata_for_whole_folder(args[:path_to_folder], args[:scope])
    end

    # run a record export end to end, starting with  identifying the correct
    # records and exporting them from the existing fedora 3 repository
    # The script runs interactively
    # TODO add in call to metadata extraction.
    desc 'interactive task to identify and export foxml records '
    task :do_all_extraction_tasks do
      STDOUT.puts 'ENTER FEDORA PASSWORD'
      f_pwd = STDIN.gets.strip
      STDOUT.puts 'ENTER FEDORA HOST'
      host = STDIN.gets.strip
      STDOUT.puts 'ENTER DIGILIB PASSWORD'
      dlib_pwd = STDIN.gets.strip
      STDOUT.puts 'ENTER PIDFILE NAME (WITHOUT FILE EXTENSION)'
      pidfile = STDIN.gets.strip
      STDOUT.puts 'ENTER DIR ON LOCAL SERVER TO EXPORT FILES TO'
      to_dir = STDIN.gets.strip
      STDOUT.puts 'ENTER RECORD TYPE(thesis or exam_paper)'
      record_type = STDIN.gets.strip
      # string tasks together by simply listing
      Rake::Task['metadata_extraction_tasks:get_pids'].invoke(f_pwd, host, pidfile, dlib_pwd, record_type)
      puts ' list of theses pids is now  on remote fedora client '
      Rake::Task['metadata_extraction_tasks:export_records'].invoke(host, dlib_pwd, f_pwd, pidfile, to_dir)
    end
end
