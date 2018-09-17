#!/usr/bin/env ruby
require 'nokogiri'

# extract the key metadata elements from the dublin core datastream
class DublinCoreElementsExtractor
  def initialize(doc)
    @doc = doc
    @key_metadata = {}
    @current_dc_version = ''
    @ns = ''
    # we already know these should always be present
    @headers = %w[pid title date rights_link rights_holder rights_statement]
  end

  # we just want to get the column headers for this
  def collect_headers
    @ns = @doc.collect_namespaces
    get_current_dc_version
    multi_value_elements = %w[creator publisher subject description]
    multi_value_elements.each do |mve|
      extract_multivalued_element_headers(mve)
    end
    extract_qualification_name_headers
    extract_qualification_level_headers
    extract_module_headers
    @headers
  end

  def get_current_dc_version
    nums = @doc.xpath('//foxml:datastream[@ID="DC"]/'\
      'foxml:datastreamVersion/@ID', @ns)
    all = nums.to_s
    current = all.rpartition('.').last
    @current_dc_version = 'DC.' + current
  end

  #  extract the metadata values and putting them into a hash
  def extract_key_metadata
    @ns = @doc.collect_namespaces # nokogiri cant resolve nested namespaces, fixes
    pid = @doc.xpath('//foxml:digitalObject/@PID', @ns).to_s
    # remove  'york:' prefix; is always 'york:' complicates choice of separators
    pid = pid.gsub 'york:', ''
    @key_metadata[:pid] = pid
    get_current_dc_version
    multi_value_elements = %w[creator publisher subject description]
    single_value_elements = %w[title date]
    single_value_elements.each do |sve|
      extract_single_valued_element(sve)
    end
    multi_value_elements.each do |mve|
      extract_multivalued_element(mve)
    end
    extract_qualification_names
    extract_qualification_levels
    extract_modules
    extract_rights
    @key_metadata
  end

  # generic method to return  values where element is a simple text
  # value which may occur  0:n times in a single dc version
  def extract_multivalued_element(element_name)
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:' + element_name + '/text()'
    @doc.xpath(path, @ns).each do |s|
      keyname = element_name
      i += 1
      keyname += i.to_s
      @key_metadata[keyname.to_sym] = s.to_s
    end
    if i.zero?
      element_name += '1'
      @key_metadata[element_name.to_sym] = ''
    end
  end

  def extract_multivalued_element_headers(element_name)
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:' + element_name + '/text()'
    @doc.xpath(path, @ns).each do
      i += 1
      @headers.push(element_name + i.to_s)
    end
  end

  # generic method to return single value where element is a simple text value
  # which may occur  0:1 times in a single dc version
  def extract_single_valued_element(element_name)
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
    'oai_dc:dc/dc:' + element_name + '/text()'
    element = @doc.xpath(path, @ns).to_s
    element = '' if element.empty?
    @key_metadata[element_name.to_sym] = element
  end

  def extract_qualification_names
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:type/text()[not(contains(.,"Text")) and not (contains(.,"Exam"))'\
    'and not (contains(.,"Collection"))and not (contains(.,"exam paper"))'\
    'and not (contains(.,"achelors"))and not (contains(.,"asters"))'\
    'and not (contains(.,"iplomas")) and not (contains(.,"octoral"))'\
    'and not (contains(.,"CEFR")) and not (contains(.,"oundation"))]'
    @doc.xpath(path, @ns).each do |s|
      keyname = 'qualification_name'
      i += 1
      keyname += i.to_s
      @key_metadata[keyname.to_sym] = s.to_s
    end
  end

  def extract_qualification_name_headers
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:type/text()[not(contains(.,"Text")) and not (contains(.,"Exam"))'\
    'and not (contains(.,"Collection"))and not (contains(.,"exam paper"))'\
    'and not (contains(.,"achelors"))and not (contains(.,"asters"))'\
    'and not (contains(.,"iplomas")) and not (contains(.,"octoral"))'\
    'and not (contains(.,"CEFR")) and not (contains(.,"oundation"))]'
    @doc.xpath(path, @ns).each do
      header_name = 'qualification_name'
      i += 1
      header_name += i.to_s
      @headers.push(header_name)
    end
  end

  # remove initial letter from words to match as Nokogiri xpath does not support
  # case insensitivity well - suggested solution is to use
  # [contains(translate(TITLE,'ABCDEFGHIJKLMNOPURSTUWXYZ',
  # 'abcdefghijklmnopurstuwxyz') - very unwieldy for multiple clauses
  # see https://stackoverflow.com/questions
  # /41914979/how-do-i-make-my-nokogiri-contains-case-insensitive
  def extract_qualification_level_headers
    puts
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:type/text()[(contains(.,"achelors")) or (contains(.,"asters"))'\
    'or (contains(.,"iplomas")) or (contains(.,"octoral")) or'\
    ' (contains(.,"CEFR")) or (contains(.,"oundation")) ]'
    @doc.xpath(path, @ns).each do
      header_name = 'qualification_level'
      i += 1
      header_name += i.to_s
      @headers.push(header_name)
    end
  end

  # remove initial letter from matches as  Nokogiri xpath does not support
  # case insensitivity well
  def extract_qualification_levels
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:type/text()[(contains(.,"achelors")) or (contains(.,"asters"))'\
    'or (contains(.,"iplomas")) or (contains(.,"octoral")) or'\
    ' (contains(.,"CEFR")) or (contains(.,"oundation")) ]'
    @doc.xpath(path, @ns).each do |s|
      keyname = 'qualification_level'
      i += 1
      keyname += i.to_s
      @key_metadata[keyname.to_sym] = s.to_s
    end
  end

  # extract only the dc:identifier values which identify modules, discard pids
  def extract_modules
    i = 0
    path = "//foxml:datastream[@ID='DC']/foxml:datastreamVersion"\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    "/dc:identifier/text()[not(starts-with(.,'york')) ]"
    @doc.xpath(path, @ns).each do |s|
      keyname = 'module'
      i += 1
      keyname += i.to_s
      @key_metadata[keyname.to_sym] = s.to_s
    end
  end

  def extract_module_headers
    i = 0
    path = '//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:identifier/text()[not(starts-with(.,"york")) ]'
    @doc.xpath(path, @ns).each do
      header_name = 'module'
      i += 1
      header_name += i.to_s
      @headers.push(header_name)
    end
  end

  # within dc:rights we can distinguish the 3 distinct elements
  def extract_rights
    rights_link = @doc.xpath('//foxml:datastream[@ID="DC"]/foxml:datastreamVersion'\
    "[@ID='#{@current_dc_version}']/foxml:xmlContent/oai_dc:dc"\
    '/dc:rights/text()[starts-with(.,"http")]', @ns).to_s
    @key_metadata['rights_link'.to_sym] = rights_link.to_s
    rights_holder = @doc.xpath('//foxml:datastream[@ID="DC"]/'\
      "foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
      'oai_dc:dc/dc:rights/text()[not(contains(.,"http")) and not '\
      '(contains(.,"licenses"))]', @ns).to_s
    @key_metadata['rights_holder'.to_sym] = rights_holder.to_s
    rights_statement = @doc.xpath('//foxml:datastream[@ID="DC"]/'\
      "foxml:datastreamVersion[@ID='#{@current_dc_version}']/foxml:xmlContent/"\
      'oai_dc:dc/dc:rights/text()[contains(.,"licenses")]', @ns).to_s
    @key_metadata['rights_statement'.to_sym] = rights_statement.to_s
  end
end
