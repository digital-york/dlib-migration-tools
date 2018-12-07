#!/usr/bin/env ruby
require 'cgi'
require 'shellwords'
# make a list of record pids, one per line in format york:dddd
class PidIdentifier
  # get list of pids from risearch query
  def initialize(fed_password,host,pidfile_name,digilib_pwd)
    @user = 'fedoraAdmin'
    @password = fed_password.shellescape
    @host = host.shellescape
    @pidfile_name = pidfile_name.shellescape
    @digilib_pwd = digilib_pwd.shellescape
  end

  def provide_pidlist
    pid_list_name = make_theses_pid_list
    edited_name = remove_unwanted_content(pid_list_name)
    upload_to_fedora_host(edited_name)
  end

  # extract the list of pids for theses from the server
  def make_theses_pid_list
    initial_file_dest = 'tmp/' + @pidfile_name + '_unedited.txt'
    puts "initial_file_dest was:" + initial_file_dest
    basic_ri_url = @host + '/fedora/risearch?type=tuples&lang=sparql&format=CSV&limit=&distinct=on&dt=on'
    puts "basic_ri_url was:"+basic_ri_url
    query = CGI.escape("PREFIX dc: <http://purl.org/dc/elements/1.1/>
                            SELECT  ?record
                            WHERE {
                                    {
                                      ?record dc:type ?type .
                                      ?record dc:type 'http://purl.org/eprint/type/Thesis'
                                      OPTIONAL
                                      { ?record dc:publisher ?publisher . }
                                      FILTER regex (?type, 'aster')
                                      FILTER (!regex(?publisher,'oxford','i'))
                                      }UNION{
                                        ?record dc:type ?type .
                                        ?record dc:type 'Theses'.
                                        OPTIONAL
                                        {?record dc:publisher ?publisher .}
                                        FILTER regex (?type, 'aster')
                                        FILTER (!regex(?publisher,'oxford','i'))
                                        }UNION{
                                          ?record dc:type ?type .
                                          ?record <info:fedora/fedora-system:def/model#hasModel> <info:fedora/york:CModel-Thesis>
                                          FILTER regex (?type, 'aster')
                                        }
                                      }")
    curl_output = `curl -u #{@user}:#{@password} -X POST  '#{basic_ri_url}&query=#{query}'`
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
