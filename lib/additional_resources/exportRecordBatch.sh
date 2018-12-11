#!/bin/sh
#REM iterate through a text file containing pids
#edit to change output location, server, port etc

 USER=$1
 PWD=$2
 FEDORAHOST=$3
 EXPORT_DIR=$4
 PIDLIST=$5
 LOGFILE="export.log"
 echo "user: $USER"
 echo "password: $PWD"
 echo "fedora host to $FEDORAHOST"
 echo "export to $EXPORT_DIR"

echo  $(date -u) "started export from fedora repository" > $LOGFILE
for PID in `cat $PIDLIST`
do
echo $PID
./exportRecord.sh $USER $PWD $PID $FEDORAHOST $EXPORT_DIR  >>  $LOGFILE
done
echo $(date -u) "export from fedora repository finished" >> $LOGFILE
