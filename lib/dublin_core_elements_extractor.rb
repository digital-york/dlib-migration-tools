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
  def extract_key_metadata
    @ns = @doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces, this fixes that
    pid = @doc.xpath("//foxml:digitalObject/@PID",@ns).to_s #unique path structure
    @key_metadata[:pid] = pid
    #estabish current dc version to use before extracting any further values
    nums = @doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",@ns) #unique path structure
		all = nums.to_s
		current = all.rpartition('.').last
    @current_dc_version = 'DC.' + current
    #extract rest of key metadata
    extract_single_valued_element("title")
    extract_multivalued_element("creator") # may be department or personal name
    extract_multivalued_element("publisher") # alternate possible lcoation of department
    extract_multivalued_element("subject")
    extract_multivalued_element("description")
    extract_single_valued_element("date")
    extract_multivalued_element("type") # may include model types, resource types (eg Exam paper) exam levels, Qualification names
    extract_multivalued_element("rights") # may include copyright holder, rights statement, rights url
    extract_multivalued_element("identifier") # may include pid, which we dont need twice,  but also module code    
    return @key_metadata
  end

  #generic method to return array of values where element is a simple text value which may occur  0:n times in a single dc version
  def extract_multivalued_element(element_name)
    element_array = []
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:" + element_name + "/text()"
    @doc.xpath(path,@ns).each do |s|
      element_array.push(s.to_s)
      puts "found this " + s.to_s
		end
    if element_array.size > 0
      keyname = element_name + "s"
      keyname = keyname.to_sym
      @key_metadata[keyname] = element_array
    end
  end

  #generic method to return single value where element is a simple text value which may occur  0:1 times in a single dc version
  def extract_single_valued_element(element_name)
    element = ""
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc/dc:" + element_name + "/text()"
    element = @doc.xpath(path,@ns).to_s
    puts "found this " +element
    if element.length > 0
      keyname = element_name.to_sym
      @key_metadata[keyname] = element
    end
  end

end
