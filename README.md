# README



This repository is a minimised non samvera/fedora app - just rake tasks to get metadata text out of foxml and put it into text files. No models, dlibhydra, authorities etc.

1)date quality checking. 
this  takes as its  input parameter the path of a directory containing foxml. All the foxml should be at this level as the script will not recurse through subdirecties. The script will read the date and normalise it into a standard format : yyyy-mm-dd. A list of all those normalised dates which have been changed from their original format will then be output to a text file (DATE OUT :), corrected_dates_list.txt (by default at the root level, this could be changed). An additional parameter "more" can be supplied which will output the names of those foxml files with non standard date formats and the original, unnormalised dates in addition to the normalised dates (FILE: DATE IN: DATE OUT:2013). Not all dates can be normalised - for example typos where extra digits have been added, these will be listed in both output file versions, but only identifiable in the extended information by eyeballing the DATE IN: entry.

Note the script  does not actually edit the foxml files themselves.

Requires:
nokogiri installed
if not already present, run bundle install

To run 
1) From the command line within the dlib-migration-tools folder, call rake date_manipulation_tasks:check_all_date_formats["<path to folder containing foxml>"] for minimal info  OR 
rake date_manipulation_tasks:check_all_date_formats["<path to folder containing foxml", "more">] for expanded info 


To simply test the class or the normalisation of a particular known date format:
1)navigate into the root of dlib-migration_tools 
2) run: ruby date_normaliser.rb
3)type in a date (digits only, no words)at the user prompt
4)normalised date will be output to the command line 

Further Work needed
1) This script checks the files but does not actually change them - we need to consider how and where this will happen
2)Similar checks could be applied to other data elements which need to be in a standard format - possibly department and institution names, qualification names, qualification levels. These would be more complex because in some cases not all the data elements are present, and in my existing ingest scripts their value is in this case inferred from the value of other data elements. In other cases the data value is present but has been added into a different data element.

