# README

DESCRIPTION OF PROJECT
This project contains  rake tasks to extract metadata out of foxml files
INPUTS: Foxml files within a flat folder containing foxml files only and no subfolders. This must be on a location on the machine running the application or a mapped drive accessible to it
OUTPUTS: CSV file containing key metadata from all the foxml records found in the specified folder, one per line. No data normalisation at this point, although some data elements - for example the various dc:rights elements - have been filtered into  distinct elements according to their content, or in some cases excluded as irrelevant (dc:type ="Text" being one such case)

REQUIRES
ruby
rake
nokogiri (if not already present, run bundle install )

TO RUN METADATA EXTRACTION
command line call as follows from within the project folder:  
rake metadata_extraction_tasks:run_metadata_collection_for_folder[<"/path/to/folder"><full|dc|dc_plus_content_location>,<"/path_to_output_location">]
eg for example rake metadata_extraction_tasks:run_metadata_collection_for_folder["../all_exams_latest","dc_plus_content_location","tmp"]

INPUT PARAMETERS
The first input parameter is the path to the folder containing the foxml files
The second input parameter specifies which  datastreams to extract metadata from, and is mandatory.
  dc = Dublin Core only
  dc_plus_content_location = Dublin Core metadata plus the present locations of all associated content files (ie the actual pdfs, wavs, jpgs)
  full =  Dublin Core (all key metadata), content locations,  ACL (user role permissions) and RELS-EXT (collection membership and object model information)
The final output path parameter is optional - default is to PROJECT_ROOT/tmp

DETAILED INFORMATION  ABOUT THE OUTPUT
In order to make the data more readable, header names have been allocated to the columns
based on the element names. This makes it easier to cross check the data types and values present across files. Where a data element may have multiple values each has been allocated to a different header eg creator1, creator2.
