#!/usr/bin/env ruby
require_relative 'date_normaliser.rb'
require_relative 'department_normaliser.rb'
require_relative 'qualification_name_normaliser.rb'

# class to co-ordinate data normalisation
class MetadataNormaliser
  def normalise_metadata(key_metadata)
    normalise_date(key_metadata)
    normalise_department_names(key_metadata)
    normalise_qualifications(key_metadata)
  end

  def normalise_date(key_metadata)
    if key_metadata.key?(:date)
      normaliser = DateNormaliser.new
      date = key_metadata.fetch(:date)
      normalise_date = normaliser.normalise(date)
      if normalise_date.to_s.empty?
        title = key_metadata.fetch(:title)
        normalise_date = normaliser.try_to_extract_date_from_title(title)
      end
      key_metadata[:date] = normalise_date unless normalise_date.to_s.empty?
    end
    key_metadata
  end

  def normalise_department_names(key_metadata)
    dept_keys_array = get_department_keys(key_metadata)
    dept_normaliser = DepartmentNormaliser.new unless dept_keys_array.empty?
    dept_keys_array.each do |k|
      name = key_metadata.fetch(k)
      standard_name = dept_normaliser.normalise_name(name) unless name.empty?
      key_metadata[k] = standard_name unless standard_name.nil?
    end
    key_metadata
  end

  def normalise_qualifications(key_metadata)
    quals_name_keys_array = get_qualification_name_keys(key_metadata)
    quals_name_normaliser = QualificationNameNormaliser.new unless quals_name_keys_array.empty?
    quals_name_keys_array.each do |q|
      qual_name = key_metadata.fetch(q)
      standard_qname = quals_name_normaliser.normalise(qual_name) unless qual_name.empty?
      key_metadata[q] = standard_qname unless standard_qname.nil?
    end
    key_metadata
  end

  def get_department_keys(key_metadata)
    # identify keys for both possible sets of sources (creatorX,publisherX)
    # return as array
    # https://www.safaribooksonline.com/library/view/ruby-cookbook/0596523696/ch05s15.html
    creators_hash = key_metadata.select { |k, _| k.to_s.include? 'creator' }
    publishers_hash = key_metadata.select { |k, _| k.to_s.include? 'publisher' }
    depts_hash = creators_hash.merge(publishers_hash)
    depts_hash.keys
  end

  def get_qualification_name_keys(key_metadata)
    # identify  keys relating to qualification names and levels, return as array
    quals_hash = key_metadata.select { |k, _| k.to_s.include? 'qualification_name' }
    quals_hash.keys
  end
end
