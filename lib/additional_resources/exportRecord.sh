#!/bin/bash

scriptdir=`dirname "$0"`
. "$scriptdir"/env-client.sh

# Exports a single foxml record
#https://wiki.duraspace.org/display/FEDORA34/Client+Command-line+Utilities#ClientCommand-lineUtilities-export. 

echo "got user $1 and password $2"
USER=$1 
PWD=$2
PID=$3
TRIMMED_PID="$(echo -e "${PID}" | tr -d '[:space:]')"
HOST=$4
EXPORT_DIR=$5

args="\"$HOST:80\" \"$1\" \"$2\" \"$TRIMMED_PID\" \"info:fedora/fedora-system:FOXML-1.1\" \"migrate\" \"$EXPORT_DIR\" \"http\" "

execWithTheseArgs org.fcrepo.client.utility.export.Export "$args"
exit $?
