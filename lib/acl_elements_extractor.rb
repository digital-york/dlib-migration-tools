#!/usr/bin/env ruby
require 'nokogiri'

# methods to extract essential acl data from foxml file
class AclElementsExtractor
  def initialize(doc)
    @doc = doc
    @key_metadata = {}
    @ns = ''
  end

  # does the meat of extracting the metadata values and inserting into  hash
  def extract_key_metadata
    # nokogiri out of box doesnt resolve nested namespaces, this fixes that
    @ns = @doc.collect_namespaces
    # extract rest of key metadata
    extract_acl_role_values # can be used to determine permissions
  end

  # extract role and value. will be complex to interpret as ACL inherits down
  def extract_acl_role_values
    roles = %w[itsStaff administrator iris york public libarchStaff infoStaff]
    roles.each do |r|
      path = "//foxml:datastream[@ID='ACL']/foxml:datastreamVersion/"\
      "foxml:xmlContent/acl:container/acl:role[@name='#{r}']/text()"
      value = @doc.xpath(path, @ns).to_s
      key = r.to_sym
      @key_metadata[key] = value
    end
    @key_metadata
  end
end
