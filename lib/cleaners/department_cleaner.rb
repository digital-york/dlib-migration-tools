#!/usr/bin/env ruby
require 'English'

# class to put department values into agreed standard form
class DepartmentCleaner
  def clean_name(name)
    standard_name = match_to_preflabel(name)
    standard_name
  end

  def match_to_preflabel(name)
    name = name.downcase  #get rid of case inconsistencies
	if name.include? 'reconstruction'
	name ='University of York. Post-war Reconstruction and Development Unit'
	elsif name.include? 'applied human rights' #at top so looks for single subjects later
	name ='University of York. Centre for Applied Human Rights'
	elsif name.include? 'health economics' #at top so looks for single subjects later
	name ='University of York. Centre for Health Economics'
	elsif name.include? 'lifelong learning' #at top so looks for single subjects later
	name ='University of York. Centre for Lifelong Learning'
	elsif name.include? 'medieval studies' #at top so looks for single subjects later
	name ='University of York. Centre for Medieval Studies'
	elsif name.include? 'renaissance' #at top so looks for single subjects later
	name ='University of York. Centre for Renaissance and Early Modern Studies'
	elsif name.include? 'reviews' #at top so looks for single subjects later
	name ='University of York. Centre for Reviews and Disseminations'
	elsif name.include? 'women' #at top so looks for single subjects later
	name ="University of York. Centre for Women's Studies"
	elsif name.include? 'languages for all'
	name = 'University of York. Languages for All'
	elsif name.include? 'school of social and political science'#at top so looks for single subjects later
	    name = 'University of York. School of Social and Political Science'
	elsif name.include? 'school of politics economics and philosophy' #at top so looks for single subjects later
	    name = 'University of York. School of Politics Economics and Philosophy'
	elsif name.include? 'economics and related' #at top so looks for single subjects later
	    name =  'University of York. Department of Economics and Related Studies'
	elsif name.include? 'economics and philosophy' #at top so looks for single subjects later
	name ='University of York. School of Politics Economics and Philosophy'
	#elsif name.include? 'departments of english and history of art'   #damn! two departments to return! MUST precede history of art
	 #   name =  'University of York. Department of English and Related Literature'
	# name ='University of York. Department of History of Art'
	elsif name.include? 'history of art' #at top so looks for history later. but below english and history of art!
	    name = 'University of York. Department of History of Art'
	elsif name.include? 'electronic'
	   name ='University of York. Department of Electronic Engineering'
	elsif name.include? 'theatre'
	   name ='University of York. Department of Theatre, Film and Television'
	elsif name.include? 'physics'
	   name ='University of York. Department of Physics'
	elsif name.include? 'computer'
	   name ='University of York. Department of Computer Science'
	elsif name.include? 'psychology'
	   name ='University of York. Department of Psychology'
	elsif name.include? 'law'
	   name ='University of York. York Law School'
	elsif name.include? 'mathematics'
	   name ='University of York. Department of Mathematics'
	elsif name.include? 'advanced architectural'
	    name = 'University of York. Institute of Advanced Architectural Studies'
	elsif name.include? 'conservation'
	    name = 'University of York. Centre for Conservation Studies'
	elsif name.include? 'eighteenth century'
	    name = 'University of York. Centre for Eighteenth Century Studies'
	elsif name.include? 'chemistry'
	    name = 'University of York. Department of Chemistry'
	elsif name.include? 'history'   #ok because of order
	    name = 'University of York. Department of History'
	elsif name.include? 'sociology'
	    name =  'University of York. Department of Sociology'
	elsif name.include? 'education'
	    name = 'University of York. Department of Education'
	elsif name.include? 'music'
	    name =  'University of York. Department of Music'
	elsif name.include? 'archaeology'
	    name =  'University of York. Department of Archaeology'
	elsif name.include? 'biology'
	    name =  'University of York. Department of Biology'
	elsif name.include? 'biochemistry'
	    name =  'University of York. Department of Biology' #confirmed with metadata team
	elsif name.include? 'english and related literature'
	    name =  'University of York. Department of English and Related Literature'
	elsif name.include? 'health sciences'
	    name =  'University of York. Department of Health Sciences'
	elsif name.include? 'politics'
	    name = 'University of York. Department of Politics'
	elsif name.include? 'philosophy'
	    name =  'University of York. Department of Philosophy'
	elsif name.include? 'social policy and social work'
	    name =  'University of York. Department of Social Policy and Social Work'
	elsif name.include? 'management'
	    name =  'University of York. The York Management School'
	elsif name.include? 'language and linguistic science'
	    name = 'University of York. Department of Language and Linguistic Science'
	elsif name.include? 'hull'
	    name = 'Hull York Medical School'
	elsif name.include? 'international pathway'
	    name = 'University of York. International Pathway College'
	elsif name.include? 'school of criminology'
	    name = 'University of York. School of Criminology'
	elsif name.include? 'natural sciences'
	    name = 'University of York. School of Natural Sciences'
	elsif name.include? 'environment'
	    name = 'University of York. Environment'
  else
     name = 'COULD NOT MATCH ' + name
	end
    name
  end
end
