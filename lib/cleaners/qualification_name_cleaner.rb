# !/usr/bin/env ruby

# class to return standardised qualification names
class QualificationNameCleaner

  # a lot of variation so need to refer against arrays of possible variants
  # TODO: add other exams, check against additional docs
  def initialize
  # bachelors
  @medicine_surgery_bachelors = ['bachelor of medicine',
                                 'bachelor of surgery (mbbs)',
                                 'bachelor of surgery',
                                 'mbbs']
  @med_sci_bachelors = ['bachelor of medical science (bmedsci)',
                        'bachelor of medical science','bmedsci']
  @science_bachelors = ['batchelor of science (bsc)',
                        'bachelor of science (bsc)',
                        '"bachelor of science (bsc)"', 'bsc',
                        'bachelor of science (ba)',
                        'bachelor of science (bsc )',
                        'bachelor of science', 'bachelor of science (bsc)',
                        'bachelor of science (msc)']
  @art_bachelors = ['batchelor of arts (ba)', '"bachelor of arts (ba),"', 'ba',
                    'bachelor of arts (ba)', 'bachelor of art (ba)',
                    'bachelor of arts', 'bachelor of arts (ma)']
  @philosophy_bachelors = ['bachelor of philosophy (bphil)',
                           'bachelor of philosophy', 'bphil']
  @engineering_bachelors = ['bachelor of engineering (beng)',
                            'bachelor of engineering', 'beng']
  @law_bachelors = ['bachelor of laws (llb)', 'bachelor of laws', 'llb']

  # TODO populate  other arrays later
  end

  def clean(name)
    name = name.downcase
    name = get_standard_name(name)
    name
  end

  # TODO bachelors now populated according to old code, need to check latest docs
  # TODO other xams not yet added
  def get_standard_name(name)
    if @medicine_surgery_bachelors.include? name
      standard_name = 'Bachelor of Medicine, Bachelor of Surgery (MBBS)'
    elsif @med_sci_bachelors.include? name
      standard_name = 'Bachelor of Medical Science (BMedSci)'
    elsif @science_bachelors.include? name
      standard_name = 'Bachelor of Science (BSc)'
    elsif @art_bachelors.include? name
      standard_name = 'Bachelor of Arts (Ba)'
    elsif @philosophy_bachelors.include? name
      standard_name = 'Bachelor of Philosophy (BPhil)'
    elsif @engineering_bachelors.include? name
      standard_name = 'Bachelor of Engineering (BEng)'
    elsif @law_bachelors.include? name
      standard_name = 'Bachelor of Laws (LLB)'
    else
      standard_name = 'COULD NOT MATCH ' + name
    end
    standard_name
  end
end
