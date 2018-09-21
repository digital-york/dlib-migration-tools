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
                          'bachelor of medical science', 'bmedsci']
    @science_bachelors = ['batchelor of science (bsc)',
                          'bachelor of science (bsc)', 'bsc',
                          'bachelor of science (bsc )',
                          'bachelor of science', 'bachelor of science (bsc)',
                          'bachelor of science (msc)']
    @art_bachelors = ['ba', 'bachelor of arts (ba)',
                      'bachelor of art (ba)', 'bachelor of arts']
    @philosophy_bachelors = ['bachelor of philosophy (bphil)',
                             'bachelor of philosophy', 'bphil']
    @engineering_bachelors = ['bachelor of engineering (beng)',
                              'bachelor of engineering', 'beng']
    @law_bachelors = ['bachelor of laws (llb)', 'bachelor of laws', 'llb']

    # Masters
    @philosophy_masters_by_pubs = ['master of philosophy by publications (mphil)',
                                   'master of philosophy by publications']
    @philosophy_masters = ['master of philosophy (mphil)', 'mphil']
    @art_masters_by_research = ['master of arts (by research) (ma (by research)',
                                'master of arts (by research)',
                                'master of arts by research (mres)']
    @art_masters = ['master of arts (ma)', 'master of arts', 'master of art (ma)',
                    'ma (master of arts)', 'masters of arts (ma)', 'ma']
    @science_masters_by_research = ['master of science (by research)']
    @science_masters_by_thesis = ['master of science (by thesis)',
                                  'msc (by thesis)']
    @science_masters = ['"master of science (msc),"',"'master of science (msc)",
                        'master of science (msc)', 'msc', 'master of science']
    @laws_masters = ['master of laws (llm)', 'master of laws', 'llm']
    @law_masters = ['master of law (mlaw)', 'master of law', 'mlaw'] # not typo!
    @public_admin_masters = ['master of public administration (mpa)',
                             'master of public administration', 'mpa']
    @biology_masters = ['master of biology (mbiol)', 'master of biology', 'mbiol']
    @bio_chem_masters = ['master of biochemistry (mbiochem)',
                         'master of biochemistry', 'mbiochem']
    @bio_med_masters = ['master of biomedical science (mbiomedsci)',
                        'master of biomedical science', 'mbiomedsci']
    @chemistry_masters = ['master of chemistry (mchem)','master of chemistry',
                          'mchem']
    @engineering_masters = ['master of engineering (meng)',
                            'master of engineering','meng']
    @math_masters = ['master of mathematics (mmath)',
                     'master of mathematics (mmath)', 'master of mathematics',
                     'mmath']
    @physics_masters = ['master of physics (mphys)', 'master of physics', 'mphys']
    @psych_masters = ['master of psychology (mpsych)', 'master of psychology',
                      'mpsych']
    @env_masters = ['master of environment (menv)', 'master of environment',
                    'menv']
    @nursing_masters = ['master of nursing', 'master of nursing (mnursing)',
                        '(mnursing)']
    @public_health_masters = ['master of public health (mph)',
                              'master of public health', 'mph']
    @social_work_masters = ['master of social work and social science (mswss)',
                            'master of social work and social science',
                            '(mswss)']
    @research_masters = ['master of research (mres)', 'master of research (mres)',
                         'mres', 'mres']
    # TODO: populate  other arrays later

    # doctorates
    @letters_docts = ['doctor of letters (dLitt)', 'doctor of Letters',
                      'dLitt']
    @music_docts = ['doctor of music (dmus)', 'doctor of music', 'dmus']
    @science_docts = ['doctor of science (scd)', 'doctor of science', 'scd']
    @engineering_docts = ['doctor of engineering (engd)',
                          'doctor of engineering', 'engd']
    @medical_docts_by_pubs = ['doctor of Medicine by publications (md)',
                              'doctor of medicine by publications']
    @medical_docts = ['doctor of Medicine (md)', 'md']
    @philosophy_docts_by_pubs = ['doctor of philosophy by publications (phd)',
                                 'doctor of philosophy by publications']
    @philosophy_docts = ['doctor of philosophy (phd)', 'phd']
  end

  def clean(name)
    name = name.downcase
    name = get_standard_name(name)
    name
  end

  # TODO bachelors now populated according to old code, need to check latest docs
  # TODO other xams not yet added
  def get_standard_name(name)
    # BACHELORS
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
    # MASTERS
    elsif @philosophy_masters_by_pubs.include? name
      standard_name = 'Master of Philosophy by publications (MPhil)'
    elsif @philosophy_masters.include? name
      standard_name = 'Master of Philosophy (MPhil)'
    elsif @art_masters_by_research.include? name
      standard_name = 'Master of Arts (by research) (MA (by research))'
    elsif @art_masters.include? name
      standard_name = 'Master of Arts (MA)'
    elsif @science_masters_by_research.include? name
      standard_name = 'Master of Science (by research) (MSc (by research))'
    elsif @science_masters_by_thesis.include? name
      standard_name = 'Master of Science (by thesis) (MSc (by thesis))'
    elsif @science_masters.include? name
      standard_name = 'Master of Science (MSc)'
    elsif @laws_masters.include? name
      standard_name = 'Master of Laws (LLM)'
    elsif @law_masters.include? name
      standard_name = 'Master of Law (MLaw)'
    elsif @public_admin_masters.include? name
      standard_name = 'Master of Public Administration (MPA)'
    elsif @biology_masters.include? name
      standard_name = 'Master of Biology (MBiol)'
    elsif @bio_chem_masters.include? name
      standard_name = 'Master of Biochemistry (MBiochem)'
    elsif @bio_med_masters.include? name
      standard_name = 'Master of Biomedical Science (MBiomedsci)'
    elsif @chemistry_masters.include? name
      standard_name = 'Master of Chemistry (MChem)'
    elsif @engineering_masters.include? name
      standard_name = 'Master of Engineering (MEng)'
    elsif @math_masters.include? name
      standard_name = 'Master of Mathematics (MMath)'
    elsif @physics_masters.include? name
      standard_name = 'Master of Physics (MPhys)'
    elsif @psych_masters.include? name
      standard_name = 'Master of Psychology (MPsych)'
    elsif @env_masters.include? name
      standard_name = 'Master of Environment (MEnv)'
    elsif @nursing_masters.include? name
      standard_name = 'Master of Nursing (MNursing)'
    elsif @public_health_masters.include? name
      standard_name = 'Master of Public Health (MPH)'
    elsif @social_work_masters.include? name
      standard_name = 'Master of Social Work and Social Science (MSWSS)'
    # DOCTORATES
    elsif @letters_docts.include? name
      standard_name = 'Doctor of Letters (DLitt)'
    elsif @music_docts.include? name
      standard_name = 'Doctor of Music (DMus)'
    elsif @science_docts.include? name
      standard_name = 'Doctor of Science (ScD)'
    elsif @engineering_docts.include? name
      standard_name = 'Doctor of Engineering (EngD)'
    elsif @medical_docts_by_pubs.include? name
      standard_name = 'Doctor of Medicine by publications (MD)'
    elsif @medical_docts.include? name
      standard_name = 'Doctor of Medicine (MD)'
    elsif @philosophy_docts_by_pubs.include? name
      standard_name = 'Doctor of Philosophy by publications (PhD)'
    elsif @philosophy_docts.include? name
      standard_name = 'Doctor of Philosophy (PhD)'
    else
      # UNMATCHED
      standard_name = 'COULD NOT MATCH ' + name
    end
    standard_name
  end
end
