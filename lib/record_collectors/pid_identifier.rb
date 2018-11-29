#!/usr/bin/env ruby
require 'cgi'
# make a list of record pids, one per line in format york:dddd
class PidIdentifier
  # get list of pids from risearch query
  def initialize(user,password,host)
    @user = user
    @password = password
    @host = host
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
end
