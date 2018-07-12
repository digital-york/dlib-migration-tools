#!/usr/bin/env ruby
require 'nokogiri'

# extract the key metadata elements from the dublin core datastream
class DublinCoreElementsExtractor
  def initialize(doc)
    @doc = doc
    @key_metadata = {}
    @current_dc_version = ''
    @ns = ''
  end

  #  extract the metadata values and putting them into a hash
  def extract_key_metadata
    @ns = @doc.collect_namespaces # nokogiri doesnt resolve nested namespaces, this fixes
    pid = @doc.xpath("//foxml:digitalObject/@PID",@ns).to_s
    @key_metadata[:pid] = pid
    # estabish current dc version to use before extracting any further values
    nums = @doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID",@ns) #unique path structure
		all = nums.to_s
		current = all.rpartition('.').last
    @current_dc_version = 'DC.' + current
    extract_single_valued_element('title')
    extract_multivalued_element('creator') # may be department or personal name
    extract_multivalued_element('publisher') # alternate  location of department
    extract_multivalued_element('subject')
    extract_multivalued_element('description')
    extract_single_valued_element('date')
    extract_multivalued_element('type') # can be model types, resource types (eg Exam paper) exam levels, Qualification names
    extract_multivalued_element('rights') # can be copyright holder, rights statement, rights url
    extract_multivalued_element('identifier') # can be pid,but also module code
    return @key_metadata
  end

  # generic method to return array of values where element is a simple text
  # value which may occur  0:n times in a single dc version
  def extract_multivalued_element(element_name)
    element_array = []
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion"\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:' + element_name + '/text()'
    @doc.xpath(path, @ns).each do |s|
      element_array.push(s.to_s)
    end
    if element_array.size > 0
      keyname = element_name + 's'
      keyname = keyname.to_sym
      @key_metadata[keyname] = element_array
    end
  end

  # generic method to return single value where element is a simple text value
  # which may occur  0:1 times in a single dc version
  def extract_single_valued_element(element_name)
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion"\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
    "oai_dc:dc/dc:" + element_name + "/text()"
    element = @doc.xpath(path, @ns).to_s
    if element.length > 0
      keyname = element_name.to_sym
      @key_metadata[keyname] = element
    end
  end
end
