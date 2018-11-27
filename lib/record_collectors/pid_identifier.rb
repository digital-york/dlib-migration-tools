#!/usr/bin/env ruby
require 'cgi'

class PidIdentifier
  # get list of pids from risearch query
  def initialize(user,password,host)
    @user = user
    @password = password
    @host = host
  end

  def get_pid_list
    basic_theses_ri_url = @host + "/fedora/risearch?type=tuples&lang=sparql&format=CSV&limit=&distinct=on&dt=on"
    theses_query = CGI.escape("PREFIX dc: <http://purl.org/dc/elements/1.1/>
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
    curl_output = `curl -u #{@user}:#{@password} -X POST  '#{basic_theses_ri_url}&query=#{theses_query}'`
    File.write('tmp/theses_sparql_outtput.tmp',curl_output)
  end
end
