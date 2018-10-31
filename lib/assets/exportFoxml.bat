@echo off
REM Exports a single foxml record
REM https://wiki.duraspace.org/display/FEDORA34/Client+Command-line+Utilities#ClientCommand-lineUtilities-export. edit to change output location, server, port etc
REM info:fedora/fedora-system:FOXML-1.1 is the export format
set FEDORA_HOME=C:\Fedora
set CATALINA_HOME=C:\Fedora\tomcat
set JAVA_HOME=

fedora-export <host>:<port> %1 %2 %3 info:fedora/fedora-system:FOXML-1.1 migrate <fully qualified name of folder to export files into> http
