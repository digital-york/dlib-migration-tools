# README

This repository is a minimised non samvera/fedora app - just rake tasks to get metadata text out of foxml and put it into text/csv files.  No models, dlibhydra, authorities etc.

1)date quality checking.
this  takes as its  input parameter the path of a directory containing foxml. All the foxml should be at this level as the script will not recurse through subdirecties. The script will read the date and normalise it into a standard format : yyyy-mm-dd. A list of all those normalised dates which have been changed from their original format will then be output to a text file (DATE OUT :), corrected_dates_list.txt (by default at the root level, this could be changed). An additional parameter "more" can be supplied which will output the names of those foxml files with non standard date formats and the original, unnormalised dates in addition to the normalised dates (FILE: DATE IN: DATE OUT:2013). Not all dates can be normalised - for example typos where extra digits have been added, these will be listed in both output file versions, but only identifiable in the extended information by eyeballing the DATE IN: entry.

2)department name test_normalisation
Normalisation of department names.


Note the script  does not actually edit the foxml files themselves.

Requires:
nokogiri installed
if not already present, run bundle install

TO RUN DATE CHECKING
1) From the command line within the dlib-migration-tools folder, call rake date_manipulation_tasks:check_all_date_formats["/path/to/folder/containing/foxml"] for minimal info  
OR
rake date_manipulation_tasks:check_all_date_formats["/path/to/folder/containing/foxml", "more"] for expanded info


To simply test the class or the normalisation of a particular known date format:
1)navigate into the root of dlib-migration_tools
2) run: ruby date_normaliser.rb
3)type in a date (digits only, no words)at the user prompt
4)normalised date will be output to the command line


TO RUN DEPARTMENT NAME CHECKING
A) ON A SINGLE FILE
1) From the command line within the dlib-migration-tools folder, call rake department_manipulation_tasks:test["/path/to/foxmlfile"] for minimal info  where a standard department name could not be found
OR
department_manipulation_tasks:test["/path/to/foxmlfile", "more"] for expanded info where a standard department name could not be found
OR
department_manipulation_tasks:test["/path/to/foxmlfile", "show_all"] for expanded info in all cases

B}BATCH CHECK ON A FOLDER
1) From the command line within the dlib-migration-tools folder, call rake department_manipulation_tasks:batch_check_department_names["/path/to/foxml/folder"] for minimal info  where a standard department name could not be found
OR
department_manipulation_tasks:batch_check_department_names["/path/to/foxml/folder", "more"] for expanded info where a standard department name could not be found
OR
department_manipulation_tasks:batch_check_department_names["/path/to/foxml/folder", "show_all"] for expanded info on all the foxml files

TO RUN CSV CREATION
This is in progress. no logging as yet although csv output is in place
1) to make csv for a single file
From the command line within the dlib-migration-tools folder, call rake create_csv_tasks:make_csv["/path/to/foxmlfile"]
2)to batch create csv for a folder: From the command line within the dlib-migration-tools folder, call rake create_csv_tasks:batch_make_csv["/path/to/foxml/folder"]

THIS BRANCH
Aims: abstract out foxml metadata extraction
Outputs:
  *class to handle reading from foxml. passed open foxml handle as a parameter. returns hash of key metadata elements and values. in first instance for DC. No standardisation at this point.
  *class to take hash from the above and create csv output from unnormalised data (could maybe do this as name:value pairs). Takes file_doc as input parameter to specify where to write csv file.
  *overall task tying the above together.  task takes an output location as a parameter, and sets a default if no parameter set. Then calls the metadata extraction task and feeds the output hash to the csv creator

  TO RUN METADATA EXTRACTION
  at present this just runs on a single file
  call rake metadata_extraction_tasks:run_metadata_collection[<"/path/to/file">,<SCOPE OF DS EXTRACTION*>,<"/path_to_output_location">]
  *where SCOPE OF DS EXTRACTION will be either 'full' or 'ds'.
  'full' returns essential metadata for dublin core, acl, rels ext and the location of the main exam paper file. 'ds' return the dublin core metadata only
  the output is in the form of a csv file. the path_to_output_location is an optional parameter which defaults to dlib-migration-tools/tmp  the name of the file is not at present configurable and is exam_papers_key_metadata.csv.
  there is still much to be done! 




Further Work needed

1)Similar checks could be applied to other data elements which need to be in a standard format - possibly institution names, qualification names, qualification levels. Note that in some cases not all the data elements are present, and in my existing ingest scripts their value is in this case inferred from the value of other data elements. In other cases the data value is present but has been added into a different data element. This adds complexity.
