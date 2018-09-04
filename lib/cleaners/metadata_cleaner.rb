#!/usr/bin/env ruby
require_relative 'date_cleaner.rb'

# class to co-ordinate data cleaning
class MetadataCleaner
  def clean_metadata(key_metadata)
    clean_date(key_metadata)
  end

  def clean_date(key_metadata)
    if key_metadata.key?(:date)
      cleaner = DateCleaner.new
      date = key_metadata.fetch(:date)
      clean_date = cleaner.clean(date)
      key_metadata[:date] = clean_date unless clean_date.to_s.empty?
    end
    key_metadata
  end
end
