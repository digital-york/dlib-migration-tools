#!/usr/bin/env ruby
require 'cgi'
require 'shellwords'
require_relative 'ri_search_query.rb'
# make a list of record pids, one per line in format york:dddd
class PidIdentifier
  # get list of pids from risearch query
  def initialize(fed_password,host,pidfile_name,digilib_pwd)
    @user = 'fedoraAdmin'
    @password = fed_password.shellescape
    @host = host.shellescape
    @pidfile_name = pidfile_name.shellescape
    @digilib_pwd = digilib_pwd.shellescape
    testsplit = ' this is a very long string \
    which needs splitting over several lines like this'
    puts testsplit

  end

  # extract the list of pids for theses from the server
  def provide_pidlist(record_type)
    pid_list_file = make_pid_list(record_type)
    edited_file = remove_unwanted_content(pid_list_file)
    upload_to_fedora_host(edited_file)
  end

  def make_pid_list(record_type)
    initial_file_dest = 'tmp/' + @pidfile_name + '_unedited.txt'

    case record_type
    when /thesis/
      query_lang = 'sparql'
    when /exam_paper/
      query_lang = 'itql'
    else
      puts 'record_type ' + record_type + ' not recognised'
    end
    base_ri_url = @host + '/fedora/risearch?type=tuples&lang=' + query_lang + \
    '&format=CSV&distinct=on&dt=on'
    search_query = RiSearchQuery.new
    risearch_string = search_query.query(record_type)
    query = CGI.escape(risearch_string)
    search_string = base_ri_url + '&query=' + query
    auth = @user + ':' + @password
    curl_output = `curl -u #{auth} -X POST '#{search_string}'`
    File.write(initial_file_dest, curl_output)
    initial_file_dest
  end

  # remove unwanted first line and pid prefixes from list
  def remove_unwanted_content(infile)
    outfile_name = 'tmp/' + @pidfile_name + '.txt'
    outfile = File.open(outfile_name, 'a')
    File.readlines(infile).drop(1).each do |line|
      wanted = line.strip
      parts = wanted.split('y')
      pid = parts[1].strip
      outfile.puts 'y' + pid
    end
    outfile.close
    outfile_name
  end

  # send list of pids to fedora client on remote server
  def upload_to_fedora_host(pidfile)
    client_dir = '/opt/york/digilib/fedora/client/bin'
    digilib_user = 'digilib'
    remote_destination = digilib_user + '@' + @host + ':' + client_dir
    puts 'sending ' + pidfile + ' to ' + remote_destination
    # scp command runs on local machine
    cmd = " sshpass -p #{@digilib_pwd} scp #{pidfile} #{remote_destination} "
    system("#{cmd}")
    puts 'pidlist sent to ' + remote_destination
  end
end
