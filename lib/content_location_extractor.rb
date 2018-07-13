#!/usr/bin/env ruby
require 'nokogiri'

# extract locations of binary resources
class ContentLocationExtractor
  def initialize(doc)
    @doc = doc
    @key_metadata = {}
    @current_exam_paper_version = ''
    @ns = ''
  end

  # this will do the meat of extracting the content locations. there should be
  # one main resource and 0:n others
  def extract_key_metadata
    # nokogiri out of box doesnt resolve nested namespaces, this fixes that
    @ns = @doc.collect_namespaces
    # estabish current ds version to use before extracting any further values
    extract_main_resource_location('EXAM_PAPER')
    @key_metadata
  end

  def extract_main_resource_location(main_resource_id)
    nums = @doc.xpath("//foxml:datastream[@ID='#{main_resource_id}']"\
      "[@STATE='A']/foxml:datastreamVersion/@ID", @ns)
    all = nums.to_s
    current = all.rpartition('.').last
    @current_exam_paper_version = 'EXAM_PAPER.' + current
    path = "//foxml:datastream[@ID='EXAM_PAPER']/foxml:datastreamVersion"\
    "[@ID='#{@current_exam_paper_version}']/foxml:contentLocation/@REF"
    content_location = @doc.xpath(path, @ns).to_s
    return if content_location.length.zero?
    @key_metadata[:main_resource_location] = content_location
  end
end
