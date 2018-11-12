# !/usr/bin/env ruby
require 'English'

#  class to put department values into agreed standard form
class DepartmentNormaliser
  def normalise_name(name)
    standard_name = match_to_preflabel(name)
    standard_name
  end

  # use mimimum match pattern to find preferred name. Match order is important
  def match_to_preflabel(name)
    name = name.downcase
    case name
    when /reconstruction/
      standard_name = 'University of York. Post-war Reconstruction and'\
       ' Development Unit'
    when /applied human rights/
      standard_name = 'University of York. Centre for Applied Human Rights'
    when /health economics/
      standard_name = 'University of York. Centre for Health Economics'
    when /health sciences/
      standard_name = 'University of York. Department of Health Sciences'
    when /lifelong learning/
      standard_name = 'University of York. Centre for Lifelong Learning'
    when /medieval studies/
      standard_name = 'University of York. Centre for Medieval Studies'
    when /renaissance/
      standard_name = 'University of York. Centre for Renaissance and Early'\
       ' Modern Studies'
    when /reviews/
      standard_name = 'University of York. Centre for Reviews and'\
       ' Disseminations'
    when /women/
      standard_name = "University of York. Centre for Women's Studies"
    when /school of social and political science/
      standard_name = 'University of York. School of Social and Political'\
       ' Science'
    when /social policy/
      standard_name = 'University of York. Department of Social Policy and'\
       ' Social Work'
    when /school of politics economics and philosophy/
      standard_name = 'University of York. School of Politics Economics and'\
       ' Philosophy'
    when /politics/
      standard_name = 'University of York. Department of Politics'
    when /economics and related/
      standard_name = 'University of York. Department of Economics and Related'\
       ' Studies'
    when /economics and philosophy/
      standard_name = 'University of York. School of Politics Economics and'\
       ' Philosophy'
    when /history of art/
      standard_name = 'University of York. Department of History of Art'
    when /history/
      standard_name = 'University of York. Department of History'
    when /electronic/
      standard_name = 'University of York. Department of Electronic Engineering'
    when /theatre/
      standard_name = 'University of York. Department of Theatre, Film and'\
       ' Television'
    when /physics/
      standard_name = 'University of York. Department of Physics'
    when /computer/
      standard_name = 'University of York. Department of Computer Science'
    when /psychology/
      standard_name = 'University of York. Department of Psychology'
    when /law/
      standard_name = 'University of York. York Law School'
    when /mathematics/
      standard_name = 'University of York. Department of Mathematics'
    when /advanced architectural/
      standard_name = 'University of York. Institute of Advanced Architectural'\
       ' Studies'
    when /conservation/
      standard_name = 'University of York. Centre for Conservation Studies'
    when /eighteenth century/
      standard_name = 'University of York. Centre for Eighteenth Century
       Studies'
    when /chemistry/
      standard_name = 'University of York. Department of Chemistry'
    when /sociology/
      standard_name = 'University of York. Department of Sociology'
    when /education/
      standard_name = 'University of York. Department of Education'
    when /music/
      standard_name =  'University of York. Department of Music'
    when /archaeology/
      standard_name =  'University of York. Department of Archaeology'
    when /biology/
      standard_name =  'University of York. Department of Biology'
    when /biochemistry/ # confirmed with metadata team - recheck?
      standard_name =  'University of York. Department of Biology'
    when /english and related/ # confirmed directly with English department
      standard_name =  'University of York. Department of English and Related'\
       ' Literature'
    when /philosophy/
      standard_name =  'University of York. Department of Philosophy'
    when /management studies/
      standard_name =  'University of York. Department of Management Studies'
    when /management school/
      # older versionof department name which should be retained if match found
      standard_name =  'University of York. The York Management School'
    when /language and linguistic science/
      standard_name = 'University of York. Department of Language and'\
       ' Linguistic Science'
    when /language and lingusitic science/ # deal with common typo
      standard_name = 'University of York. Department of Language and'\
       ' Linguistic Science'
    when /for all/ # this is 'languages for all' but in some records 'language'
      standard_name = 'University of York. Department of Language and'\
       ' Linguistic Science. Languages for All'
    when /hull/
      standard_name = 'Hull York Medical School'
    when /international pathway/
      standard_name = 'University of York. International Pathway College'
    when /school of criminology/
      standard_name = 'University of York. School of Criminology'
    when /natural sciences/
      standard_name = 'University of York. School of Natural Sciences'
    when /environment and geography/  # order important, more precise must be first
      standard_name = 'University of York. Department of Environment and Geography'
    when /environment/
      standard_name = 'University of York. Environment Department'
    else
    standard_name = 'COULD NOT MATCH ' + name
    end
    standard_name
  end
end
