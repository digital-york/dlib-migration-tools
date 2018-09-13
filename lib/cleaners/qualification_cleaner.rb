# !/usr/bin/env ruby
require 'English'

# class to handle standardising qualification names and levels
# This will be quite complex as both data types are present in the same element
# In addition, the qualification level is not always present,
# in which case it should be inferred from the qualification name and added
class QualificationCleaner
  def clean(qual_data)
    cleaned_data = match_to_qual_level(qual_data)
    cleaned_data
  end

  # valid levels (unconfirmed): masters, bachelors,diplomas, lower_diplomas,
  # doctoral, cefr, foundation
  def match_to_qual_level(poss_level)
    poss_level = poss_level.downcase
    case poss_level
    when /this/
      level = 'bachelors'
    else
      level = 'COULD NOT MATCH LEVEL ' + poss_level
    end
    level
  end
end
