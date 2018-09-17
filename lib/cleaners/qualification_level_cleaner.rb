# !/usr/bin/env ruby
require 'English'

# class to handle standardising qualification names and levels
# This will be quite complex as both data types are present in the same element
# In addition, the qualification level is not always present,
# in which case it should be inferred from the qualification name and added
class QualificationLevelCleaner
  def clean(qual_data)
    cleaned_data = match_to_qualification_level(qual_data)
    cleaned_data
  end

  # valid levels (unconfirmed): masters, bachelors,diplomas, lower_diplomas,
  # doctoral, cefr, foundation
  # infer  qualification level from  standardised qualification name
  # IN PROGESS NAMES AND MATCHES UNCONFIRMED
  def get_qualification_level(standard_name)
    case standard_name
    when /Bachelor/
      level = 'Bachelors (Undergraduate)'
    when /Master/
      level = 'Masters (Postgraduate)'
    when /Postgraduate Diploma/
      level = 'Diplomas (Postgraduate)'
    when /DipHE/
      level = 'Diplomas (other)'
    when /Doctor/
      level = 'Doctoral (Postgraduate)'
    when /CEFR/
      level = 'CEFR Module'
    when /Foundation/
      level = 'Foundation'
    else
      level = 'COULD NOT FIND MATCH FOR ' + standard_name
    end
    level
  end
end
