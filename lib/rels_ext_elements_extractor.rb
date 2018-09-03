#!/usr/bin/env ruby
require 'nokogiri'

class RelsExtElementsExtractor
  def initialize(doc)
    @doc = doc
    @key_metadata = {}
    @current_rels_ext_version = ''
    @ns = ''
    @headers = ['isMemberOf']
  end

  # this will do the meat of extracting the metadata values and putting them into a hash
  def extract_key_metadata
    @ns = @doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces,
    # this fixes that
    # estabish current  version to use before extracting any further values
    determine_current_rels_ext_version
    # extract rest of key metadata
    extract_single_valued_element('rel', 'isMemberOf') # immediate parent coll
    # possible relevance, not sure if needed
    #extract_multivalued_element('fedora-model', 'hasModel')
    @key_metadata
  end

  def collect_headers
    @ns = @doc.collect_namespaces
    determine_current_rels_ext_version
    multi_value_elements = %w[hasModel]
    multi_value_elements.each do |mve|
      extract_multivalued_element_headers('fedora-model', mve)
    end
    @headers
  end

  def extract_multivalued_element_headers(element_prefix, element_name)
    i = 0
    path = "//foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion"\
    "[@ID='#{@current_rels_ext_version}']/foxml:xmlContent/rdf:RDF/"\
    "rdf:Description/#{element_prefix}:#{element_name}/@rdf:resource"
    @doc.xpath(path, @ns).each do
      i += 1
      @headers.push(element_name + i.to_s)
    end
  end

  def determine_current_rels_ext_version
    nums = @doc.xpath("//foxml:datastream[@ID='RELS-EXT']"\
    "/foxml:datastreamVersion/@ID", @ns)
    all = nums.to_s
    current = all.rpartition('.').last
    @current_rels_ext_version = 'RELS-EXT.' + current
  end

  # generic method to  values where value is an element which may
  # occur  0:n times in a single rels-ext version
  def extract_multivalued_element(element_prefix, element_name)
    i = 0
    path = "//foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion"\
    "[@ID='#{@current_rels_ext_version}']/foxml:xmlContent/rdf:RDF/"\
    "rdf:Description/#{element_prefix}:#{element_name}/@rdf:resource"
    @doc.xpath(path, @ns).each do |s|
      i += 1
      keyname = element_name
      keyname += i.to_s
      keyname = keyname.to_sym
      @key_metadata[keyname] = s.to_s
    end
  end

  # generic method to return single value where value is an element which may
  # occur  0:1 times in a single rels-ext version
  def extract_single_valued_element(element_prefix, element_name)
    path = "//foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion"\
    "[@ID='#{@current_rels_ext_version}']/foxml:xmlContent/rdf:RDF/"\
    "rdf:Description/#{element_prefix}:#{element_name}/@rdf:resource"
    element = @doc.xpath(path, @ns).to_s
    return if element.empty?
    keyname = element_name.to_sym
    @key_metadata[keyname] = element
  end
end
