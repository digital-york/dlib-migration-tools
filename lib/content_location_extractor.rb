#!/usr/bin/env ruby
require 'nokogiri'

class ContentLocationExtractor

  def initialize(doc)
    @doc = doc
		@key_metadata = Hash.new
    @current_exam_paper_version = ""
    @ns = ""
	end

  #this will do the meat of extracting the metadata values and putting them into a hash
  def extract_key_metadata
    @ns = @doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces, this fixes that
    #estabish current dc version to use before extracting any further values
    nums = @doc.xpath("//foxml:datastream[@ID='EXAM_PAPER']/foxml:datastreamVersion/@ID",@ns) #unique path structure
		all = nums.to_s
		current = all.rpartition('.').last
    @current_exam_paper_version = 'EXAM_PAPER.' + current
    idstate = doc.xpath("//foxml:datastream[@ID='EXAM_PAPER']/@STATE",@ns)


    #extract rest of key metadata
    extract_single_valued_element("rel","isMemberOf") #immediate parent collction
    extract_multivalued_element("fedora-model","hasModel") # possible relevance, not sure if needed
    return @key_metadata
  end

  #generic method to return array of values where value is an element which may occur  0:n times in a single rels-ext version
  def extract_multivalued_element(element_prefix,element_name)
    element_array = []
    path = "//foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion[@ID='#{@current_rels_ext_version}']/foxml:xmlContent/rdf:RDF/rdf:Description/#{element_prefix}:#{element_name}/@rdf:resource"
      @doc.xpath(path,@ns).each do |s|
      element_array.push(s.to_s)
		end
    if element_array.size > 0
      keyname = element_name + "s"
      keyname = keyname.to_sym
      @key_metadata[keyname] = element_array
    end
  end

  #generic method to return single value where value is an element which may occur  0:1 times in a single rels-ext version
  def extract_single_valued_element(element_prefix,element_name)
    element = ""
    path = "//foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion[@ID='#{@current_rels_ext_version}']/foxml:xmlContent/rdf:RDF/rdf:Description/#{element_prefix}:#{element_name}/@rdf:resource"
    element = @doc.xpath(path,@ns).to_s
    if element.length > 0
      keyname = element_name.to_sym
      @key_metadata[keyname] = element
    end
  end

end
