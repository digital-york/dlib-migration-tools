# README


This repository is a minimised non samvera/fedora app - just rake tasks to get metadata text out of foxml and put it into text/csv files.  No models, dlibhydra, authorities etc. Seperate normalisation tasks for dates and department names included in here, they are not at this point used in the main metadata extraction function.

METADATA EXTRACTION TASK
Aims: abstract out foxml metadata extraction
Outputs:
CSV file containing key metadata from all the foxml files in a specified folderr. one per line. Folder must contain foxml files only and no subfolders.

No normalisation at this point, although some data elements - for example the various dc:rights
elements - have been filtered into  distinct elements according to their content, or in some cases excluded as irrelevant (dc:type ="Text" being one such case)

In order to make the data more readable header names have been allocated to the columns
based on the element names. This makes it easier to cross check the data types and values present across files.

Where a data element may have multiple values each has been allocated to a different header eg creator1, creator2. Because of the way the headers are created these may not appear next to each other in the csv output.

You must specify which datastreams to include metadata from as a parameter in the command line call.
In the simplest case, dublin core output only is output. This may be the main information the content team will require. use 'dc'
A second simplified variant provides Dublin Core metadata plus the present locations of all associated content files (ie the actual pdfs, wavs, jpgs ) use 'dc_plus_content_location'
The final variant outputs all key metadata from the Dublin Core, content locations,
ACL (user role permissions) and RELS-EXT (collection membership and object model information). use 'full'

The csv file output location is also specifiable by an optional  parameter to the command line call. If not specified, it will default to <application-root-dir>/tmp. The csv file name is not specifiable, it is exam_papers_key_metadata.csv


TO RUN METADATA EXTRACTION
to run as a batch task on a flat folder containing foxml files only. This must be
on a location on the machine running the application or a mapped drive accessible to it
command line call as follows:  
rake metadata_extraction_tasks:run_metadata_collection_for_folder[<"/path/to/folder"><full|dc|dc_plus_content_location>,<"/path_to_output_location">]
eg for example rake metadata_extraction_tasks:run_metadata_collection_for_folder["../all_exams_latest","dc_plus_content_location","tmp"]

note final output path parameter is optional






Normalisation tasks: see below

These are completely separate from the main metadata extraction task. I have left them in here as they may be in part or whole useful for the data normalisation phase of the migration process.

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
  to run on a single file
  call rake metadata_extraction_tasks:run_metadata_collection[<"/path/to/file">,<SCOPE OF DS EXTRACTION*>,<"/path_to_output_location">]
  *where SCOPE OF DS EXTRACTION will be either 'full' or 'ds'.
  'full' returns essential metadata for dublin core, acl, rels ext and the location of the main exam paper file. 'ds' return the dublin core metadata only
  the output is in the form of a csv file. the path_to_output_location is an optional parameter which defaults to dlib-migration-tools/tmp  the name of the file is not at present configurable and is exam_papers_key_metadata.csv.
  there is still much to be done!

  to run as a batch task on a flat folder containing foxml files only
  rake metadata_extraction_tasks:run_metadata_collection_for_folder[<"/path/to/folder">,<"/path/to/file">,<full|dc>,<"/path_to_output_location">]
