#!/usr/bin/env ruby
require 'nokogiri'

class AclElementsExtractor

  def initialize(doc)
    @doc = doc
		@key_metadata = Hash.new
    @ns = ""
	end

  #this will do the meat of extracting the metadata values and putting them into a hash
  def extract_key_metadata
    @ns = @doc.collect_namespaces #  nokogiri out of box doesnt resolve nested namespaces, this fixes that
    #extract rest of key metadata
    extract_acl_role_values #can be used to determine permissions
    return @key_metadata
  end

  #for this we need to extract role and value. complicated as ACL cascades downwards
  def extract_acl_role_values
    roles = ['itsStaff','administrator','iris','york','public','libarchStaff','infoStaff' ]
    roles.each do |r|
        path = "//foxml:datastream[@ID='ACL']/foxml:datastreamVersion/foxml:xmlContent/acl:container/acl:role[@name='#{r}']/text()"
        value = @doc.xpath(path,@ns).to_s
        key = r.to_sym
        puts "key was " + r + " value was " + value
        @key_metadata[key] = value
    end
  end

end
