# !/usr/bin/env ruby

# class to return standardised qualification names
class QualificationNameCleaner

  # a lot of variation so need to refer against arrays of possible variants
  def initialize
  # bachelors
  @medicine_surgery_bachelors = ['bachelor of medicine',
                                 'bachelor of surgery (mbbs)',
                                 'bachelor of medicine', 'bachelor of surgery',
                                 'mbbs']
  @med_sci_bachelors = ['bachelor of medical science (bmedsci)',
                        'bachelor of medical science','bmedsci']
  @science_bachelors = ['batchelor of science (bsc)',
                        'bachelor of science (bsc)',
                        '"bachelor of science (bsc)"', 'bsc',
                        'bachelor of science (ba)','bachelor of science (bsc )',
                        'bachelor of science', 'bachelor of science (bsc)',
                        'bachelor of science (msc)']

  # TODO populate  other arrays later
  end

  def clean(name)
    name = name.downcase
    name = get_standard_name(name)
    name
  end

  def get_standard_name(name)
    if @medicine_surgery_bachelors.include? name
      standard_name = 'Bachelor of Medicine, Bachelor of Surgery (MBBS)'
    elsif @med_sci_bachelors.include? name
      standard_name = 'Bachelor of Medical Science (BMedSci)'
    elsif @science_bachelors.include? name
      standard_name = 'Bachelor of Science (BSc)'
    else
      standard_name = 'COULD NOT MATCH ' + name
    end
    standard_name
  end
end
