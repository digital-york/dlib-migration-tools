#!/usr/bin/env ruby
require 'nokogiri'

class DublinCoreElementsExtractor

  def initialize(doc)
    @doc = doc
		@key_metadata = Hash.new
    @current_dc_version = ""
    @ns = ""
	end

  #this will do the meat of extracting the metadata values and putting them into a hash
  def extract_key_metadata(doc)
    #key_metadata = Hash.new
    ns = doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces, this fixes that
    @ns = doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces, this fixes that
    pid = doc.xpath("//foxml:digitalObject/@PID",ns).to_s
    @key_metadata[:pid] =pid
    #estabish current dc version to use before extracting any further values
    nums = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",ns)
		all = nums.to_s
		current = all.rpartition('.').last
		current_dc_version = 'DC.' + current
    @current_dc_version = 'DC.' + current
    #extract rest of key metadata

    #title (should always be present, single value)
    title = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:title/text()",ns).to_s
    @key_metadata[:title] = title

    #creators (multivalue or absent)
    #creators = []
	#	doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:creator/text()",ns).each do |s|
    #    creators.push(s.to_s)
	#	end
  #  if creators.size > 0
  #    @key_metadata[:creators] = creators
  #  end
    extract_multivalued_element("creator")

    #publishers (multivalue or absent)
    publishers = []
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:publisher/text()",ns).each do |s|
        publishers.push(s.to_s)
		end
    if publishers.size > 0
      @key_metadata[:publishers] = publishers
    end

    #subject (multivalue or absent)
    subjects = []
		doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:subject/text()",ns).each do |s|
        subjects.push(s.to_s)
		end
    if subjects.size > 0
      @key_metadata[:subjects] = subjects
    end

    #rights (multivalue)
    rights = []
    doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:rights/text()",ns).each do |s|
        rights.push(s.to_s)
		end
    if rights.size > 0
      @key_metadata[:rights] = rights
    end

    #date (single value, possibly absent)
    date = doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:date/text()",ns).to_s
    if date.length > 0
      @key_metadata[:date] = date
    end

    return @key_metadata
  end

  #generic method to return array of values where element is a simple text value which may occur  0:n times in a single dc version
  def extract_multivalued_element(element_name)
    element_array = []
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:" + element_name + "/text()"
    @doc.xpath(path,@ns).each do |s|  element_array.push(s.to_s)
        puts "found this " + s.to_s
		end
    if element_array.size > 0
      keyname = element_name + "s"
      keyname = keyname.to_sym
      @key_metadata[keyname] = element_array
    end
  end

end
