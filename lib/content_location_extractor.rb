#!/usr/bin/env ruby
require 'nokogiri'

# extract locations of binary resources
class ContentLocationExtractor
  def initialize(doc)
    @doc = doc
    @key_metadata = {}
    @current_exam_paper_version = ''
    @ns = ''
    @headers = []
  end

  # this will do the meat of extracting the content locations. there should be
  # one main resource and 0:n others
  def extract_key_metadata
    # nokogiri out of box doesnt resolve nested namespaces, this fixes that
    @ns = @doc.collect_namespaces
    # estabish current ds version to use before extracting any further values
    extract_resource_locations
    @key_metadata
  end

  def collect_headers
    @ns = @doc.collect_namespaces
    path = "//foxml:datastream[@STATE='A']/foxml:datastreamVersion"\
    "/foxml:contentLocation/../../@ID"
    @doc.xpath(path, @ns).each do |id|
      @headers.push(id.to_s)
    end
    @headers
  end

  def extract_resource_locations
    #  get all  ids for paths with content locations then extract the ids
    # then run the paths for just the ids to get the content locations
    content_ids = []
    # get all the ids of ds with contentLocation
    path = "//foxml:datastream[@STATE='A']/foxml:datastreamVersion"\
    "/foxml:contentLocation/../../@ID"
    @doc.xpath(path, @ns).each do |id|
      content_ids.push(id)
    end

    # now use them to construct a path to get the ref
    content_ids.each do |cid|
      path2 = "//foxml:datastream[@STATE='A'][@ID='#{cid}']"\
      "/foxml:datastreamVersion/foxml:contentLocation/@REF"
      content_location = @doc.xpath(path2, @ns).to_s
      @key_metadata[cid] = content_location
    end
  end
end
