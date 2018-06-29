#!/usr/bin/env ruby
require 'nokogiri'

class DublinCoreElementsExtractor

  def extract_key_metadata(doc_in)
    #this will do the meat of extracting the metadata values and putting them into a hash
    #first confirm we are indeed opening the file by getting some element back
    #this is for debugging only as did not recognise the collect_namespaces method
    #from filehandle passed in as parameter.so need to find how this can be done. 
    doc = File.open("../small_data/york_666.xml"){ |f| Nokogiri::XML(f, Encoding::UTF_8.to_s)}
    ns = doc.collect_namespaces # doesnt resolve nested namespaces, this fixes that
    pid = doc.xpath("//foxml:digitalObject/@PID",ns).to_s
    puts "read the pid:"+ pid.to_s
  end
end
