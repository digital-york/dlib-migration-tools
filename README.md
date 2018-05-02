# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

This repository is a minimised non samvera/fedora app - just rake tasks to get metadata text out of foxml and put it into text files. No models, dlibhydra, authorities etc.

1)date manipulation testing. 
this will takes as its  input a text file derived from an risearch query containing a list of the current dc:date elements in the various student paper records - ie exam papers, theses, undergraduate papers, together with the pids of the fedora3 records they relate to. It then outputs a corresponding list of the dates normalised into the standard agreed format for these records (note that this format will not be the same throughout all the record types in our entire repository). If the date cannot be normalised into the expected form then the original date will be output, plus anything it was altered to, plus the pid of the record it belonged to. Such cases will be easily identifiable as everything else in the output file will be exactly the same length (and a lot shorter). 
To run 
1) with default inputs and outputs to <root of app>/tmp/examdatesin.txt and  <root of app>/tmp/examdatesout.txt 
	rake date_manipulation_tasks:check_date_normalisation
2) with optional params for input and output files
	rake date_manipulation_tasks:check_date_normalisation[tmp/yourinputfilename.txt,tmp/youroutputfilename.txt]
	
ri search used to obtain the data was 
select $object $date 
from <#ri>
where  
$object <dc:date> $date
and ( $object <fedora-model:hasModel> <fedora:york:CModel-Thesis>
  or $object <fedora-model:hasModel> <fedora:york:CModel-ExamPaper>
or $object <dc:type> 'Thesis' or $object <dc:type> 'ExamPaper'
)

Ensure unlimited option is selected, and use search/replace to remove unwanted info:fedora/ part of id (or you could just leave it in, it shouldnt matter, just looks neater without)



To use the app, do
bundle install
rake db:migrate

Would normally edit the following with your local config, but no need to do this as yet as not using fedora/solr/blacklight at this point
config/fedora.yml
config/solr.yml
config/blacklight.yml

if not using solr and fedora wrappers, edit those out of the rake file
