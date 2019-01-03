# README

DESCRIPTION OF PROJECT
This project contains  rake tasks to extract metadata from a fedora 3 repository
INPUTS: Foxml files within a flat folder containing foxml files only and no
subfolders. This must be on a location on the machine running the application or
 a mapped drive accessible to it. At present the project handles Thesis and Exam
  Paper records.

 REQUIRES
 ruby
 rake
 nokogiri (if nokogiri not already present, run bundle install )

OUTPUTS: CSV file containing key metadata from all the foxml records found in
the specified folder, one per line.
csv output files named according to the record type they contain
eg theses_key_metadata.csv

DETAILED INFORMATION  ABOUT THE OUTPUT
In order to make the data more readable, header names have been allocated to the
 columns based on the element names. This makes it easier to cross check the
 data types and values present across files. Where a data element may have
 multiple values each has been allocated to a different header eg creator1,
 creator2. Where data has a limited number of known standard forms, this has
 been normalised - dates, department names, qualification names.

TASKS AVAILABLE:
rake default task gives USAGE output (just run rake)
run rake --task | cat to see full list of available tasks and
descriptions
to see more detailed description of tasks and parameters open
lib/tasks/metadata_extraction_tasks.rake

HOW TO USE THESE TASKS

command line calls as follows from within the project folder:
1) identify and export the required records from the fedora3 repository
(interactive, parameters will be requested when you run the script)
>rake metadata_extraction_tasks:do_all_extraction_tasks
2)extract the key metadata from the exported records and output to a single
csv file. separate tasks for exam papers and theses.    
  a) EXAMS
rake metadata_extraction_tasks:collect_exam_metadata_collection_from_folder[<"/path/to/exported/foxml/folder"><full|dc|dc_plus_content_location>,<"/path_to_output_location">]
eg for example rake metadata_extraction_tasks:run_metadata_collection_for_folder["../all_exams_latest","dc","tmp"]
  b) THESES
rake metadata_extraction_tasks:collect_thesis_metadata_from_folder[<"/path/to/folder"><full|dc|dc_plus_content_location>,<"/path_to_output_location">]


The resulting csv file will contain all the key metadata, standardised where
possible,  for the required datastreams (see input parameters for more
clarification), one record per line


INPUT PARAMETERS
The first input parameter is the path to the folder containing the foxml files
The second input parameter specifies which  datastreams to extract metadata
from, and is mandatory.
  dc = Dublin Core only
  dc_plus_content_location = Dublin Core metadata plus the present locations of
   associated content files (ie the actual pdfs, wavs, jpgs)
  full =  Dublin Core (all key metadata), content locations,  ACL (user role
    permissions) and RELS-EXT (collection membership information)
other possible (but unlikely) variants: dc_plus_acl, dc_plus_rels_ext'

The final output path parameter is optional - default is to PROJECT_ROOT/tmp
