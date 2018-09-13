#!/usr/bin/env ruby
require 'English'

# class to put various date variants found in yodl into standard international
# date format yyyy-mm-dd. However month or day may not be provided in which
# case just supply elements which are there  runs against a single string
# representing a date. Known variants to normalise as follows:
# yyyy
# yyyy-mm
# yyyy mm
# mm yyyy
# mm-yyyy
# yyyy-yyyy
# dd-mm-yyyy
# yyyy-mm-dd
class DateCleaner
  # this works correctly but if the csv is opened it excel, excel displays
  # dates in format yyyy-mm-dd as dd/mm/yyyy. however opening in text editor
  # shows the date format to be correctly cleaned

  def clean(date)
    clean = ''
    year = get_year(date)
    clean = year unless year.empty?
    return if clean.empty?
    month = get_month(date)
    day = get_day(date)
    unless month.empty?
      clean = clean + '-' + month # there may also be a day
      clean = clean + '-' + day unless day.empty?
    end
    clean
  end

  # this looks for 4 digit groups, and expects either one or two. There will be
  # two in the case of a date range, in which case we use only the second date
  def get_year(date)
    year = ''
    matches = []
    # though if a year has two many digits, this will just truncate to last 4
    date.scan(/([\d]{4})/) { matches << $LAST_MATCH_INFO }
    if matches.size == 1
      year = matches[0].to_s
    elsif matches.size == 2
      year = matches[1].to_s
    end
    year
  end

  # Take the entire date and  return just the month  if it is specified.
  # range of date delimitors included space, dot,hyphen, /, \
  # needs a total of 4 backslashes to escape \ used as a date delimiter!
  # Zero pad if single digit
  def get_month(date)
    month = ''
    # if its a year range dont proceed further
    return month if /[\d]{4}[\s\-\.\/\\\\][\d]{4}/.match(date.strip)
    # year is at start so month will be first pair of digits  if present
    if /^[0-9]{4}[\s\-\.\/\\\\]([\d]{1,2})/.match(date.strip)
      month = $1
      # year is at end so month will immediately precede the year
    elsif /([\d]{1,2})[\s\-\.\/\\\\][0-9]{4}\Z/.match(date.strip)
      month = $1
    end
    month = '0' + clean_month if month.length == 1
    month
  end

  # take the string for the entire date, return the day if it is specified.
  # range of date delimitors included space, dot,hyphen, /, \
  # needs a total of 4 backslashes to escape \ used as a date delimiter!
  # zero pad if single digit
  def get_day(date)
    day = ''
    # if its a year range dont proceed further
    # needs a total of 4 backslashes to escape \ used as a date delimiter!
    return day if /[\d]{4}[\s\-\.\/\\\\][\d]{4}/.match(date.strip)
    # year at start so day will be a second pair of digits if present.
    # it wont be present without a month
    if /^[0-9]{4}[\s\-\.\/\\\\][\d]{1,2}[\s\-\.\/\\\\]([\d]{1,2})/.match(date.strip)
      day = $1
      # year is at end so day will be first of two pairs of digits if present.
      # it wont be present without a month.
    elsif /([\d]{1,2})[\s\-\.\/\\\\][\d]{1,2}[\s\-\.\/\\\\][0-9]{4}\Z/.match(date.strip)
      day = $1
    end
    day = '0' + day if day.length == 1
    day
  end
end
