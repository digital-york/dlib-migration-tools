#! /bin/bash

cat thesis_pids_unedited.txt | while read LINE; do
initial=$LINE
echo $initial | cut -d'/' -f2 >> thesis_pidlist.txt
done
