The files in this folder can be used to run an risearch query to return the ids
of all york postgraduate thesis records from the command line and output to a
text file
The machine it is being called from will need to have access permissions on the
 fedora host
 TO USE:
 edit curl_theses_query.sh, replacing <USER> <PASSWORD> and <HOST> (no port)
 run using the syntax below
 >sh curl_theses_query.sh > thesis_pids_unedited.txt

 or to include the time to run
 > time sh curl_theses_query.sh > thesis_pids_unedited.txt

 Note that before this file is used as an input to a fedora export script it
 will require editing to remove the prefix info:fedora/ from each line. The final
 line showing time metrics will also need to be removed if present.

 TODO
 need to investigate sed and awk (probably) in order to remove the unwanted
 info:fedora/ prefix from each line, before it can be used as an input to an
 automated fedora export batch file
