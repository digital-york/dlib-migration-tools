#!/usr/bin/env ruby
require 'nokogiri'

class DublinCoreElementsExtractor

  #this will do the meat of extracting the metadata values and putting them into a hash
  def extract_key_metadata(doc)
    key_metadata = Hash.new
    ns = doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces, this fixes that
    v_pid = doc.xpath("//foxml:digitalObject/@PID",ns).to_s
    key_metadata[:pid] = v_pid
    #estabish current dc version to use before extracting any further values
    nums = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",ns)
		all = nums.to_s
		current = all.rpartition('.').last
		current_dc_version = 'DC.' + current
    #extract rest of key metadata

    #creators
    creators = []
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:creator/text()",ns).each do |s|
        creators.push(s.to_s)
		end
    if creators.size > 0
      key_metadata[:creators] = creators
    end

    #publishers
    publishers = []
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:publisher/text()",ns).each do |s|
        publishers.push(s.to_s)
		end
    if publishers.size > 0
      key_metadata[:publishers] = publishers
    end


    return key_metadata

  end

end
