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
    @ns = @doc.collect_namespaces # nokogiri cant resolve nested namespaces, fixes
    pid = @doc.xpath('//foxml:digitalObject/@PID', @ns).to_s
    # remove  'york:' prefix; is always 'york:' complicates choice of separators
    pid = pid.gsub 'york:', ''
    @key_metadata[:pid] = pid
    # estabish current dc version to use before extracting any further values
    nums = @doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion/@ID", @ns)
    all = nums.to_s
    current = all.rpartition('.').last
    @current_dc_version = 'DC.' + current
    multi_value_elements = %w[creator publisher subject description type identifier]
    single_value_elements = %w[title date]
    single_value_elements.each do |sve|
      extract_single_valued_element(sve)
    end
    multi_value_elements.each do |mve|
      extract_multivalued_element(mve)
    end
    extract_rights
    @key_metadata
  end

  # generic method to return  values where element is a simple text
  # value which may occur  0:n times in a single dc version
  def extract_multivalued_element(element_name)
    i = 0
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion"\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:' + element_name + '/text()'
    @doc.xpath(path, @ns).each do |s|
      keyname = element_name
      i += 1
      keyname += i.to_s
      keyname = keyname.to_sym
      @key_metadata[keyname] = s.to_s
    end
    if i.zero?
      keyname = element_name
      keyname = keyname.to_sym
      @key_metadata[keyname] = ''
    end
  end

  # generic method to return single value where element is a simple text value
  # which may occur  0:1 times in a single dc version
  def extract_single_valued_element(element_name)
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion"\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
    "oai_dc:dc/dc:" + element_name + "/text()"
    element = @doc.xpath(path, @ns).to_s
    #return if element.empty?
    if element.empty?
      element = ''
    end
    keyname = element_name.to_sym
    @key_metadata[keyname] = element
  end

  # have made this different because we can distinguish the 3 distinct elements
  def extract_rights
    rights_link = @doc.xpath("//foxml:datastream[@ID='DC']/foxml:datastreamVersion"\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    "/dc:rights/text()[starts-with(.,'http')]", @ns).to_s
    keyname = 'rights_link'.to_sym
    @key_metadata[keyname] = rights_link.to_s
    rights_holder = @doc.xpath("//foxml:datastream[@ID='DC']/"\
      "foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
      "oai_dc:dc/dc:rights/text()[not(contains(.,'http')) and not "\
      "(contains(.,'licenses'))]", @ns).to_s
    keyname = 'rights_holder'.to_sym
    @key_metadata[keyname] = rights_holder.to_s
    rights_statement = @doc.xpath("//foxml:datastream[@ID='DC']/"\
      "foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
      "oai_dc:dc/dc:rights/text()[contains(.,'licenses')]", @ns).to_s
    keyname = 'rights_statement'.to_sym
    @key_metadata[keyname] = rights_statement.to_s
  end
end
