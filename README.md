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


Further Work needed

1)Similar checks could be applied to other data elements which need to be in a standard format - possibly institution names, qualification names, qualification levels. Note that in some cases not all the data elements are present, and in my existing ingest scripts their value is in this case inferred from the value of other data elements. In other cases the data value is present but has been added into a different data element. This adds complexity.
