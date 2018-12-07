#!/usr/bin/env ruby
require 'cgi'
require 'shellwords'
# make a list of record pids, one per line in format york:dddd
class PidIdentifier
  # get list of pids from risearch query
  def initialize(fed_user,fed_password,host)
    @user = fed_user.shellescape
    @password = fed_password.shellescape
    @host = host.shellescape
  end

  # extract the list of pids for theses from the server
  def make_theses_pid_list
    basic_ri_url = @host + "/fedora/risearch?type=tuples&lang=sparql&format=CSV&limit=&distinct=on&dt=on"
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
    File.write('tmp/theses_pids_unedited.txt',curl_output)
  end

  # remove unwanted first line and pid prefixes from list
  def remove_unwanted_content
    outfile = File.open('tmp/theses_pids.txt', 'a')
    infile = 'tmp/theses_pids_unedited.txt'
    # read in line by line
    File.readlines(infile).drop(1).each do |line|
      wanted = line.strip
      parts = wanted.split('y')
      pid = parts[1].strip
      outfile.puts 'y' + pid
    end
    outfile.close
  end

  # send list of pids to fedora client on remote server
  def upload_to_fedora_host(digilib_pwd)
    puts 'sending pidlist to fedora host'
    puts 'using digilib password ' + digilib_pwd
    pidfile = 'tmp/theses_pids.txt'
    digilib_pwd = digilib_pwd.shellescape
    client_dir = '/opt/york/digilib/fedora/client/bin'
    digilib_user = 'digilib'
    exec(" sshpass -p #{digilib_pwd} scp #{pidfile} #{digilib_user}@#{@host}:#{client_dir} ")
  end
end
