@echo off
REM Exports a single foxml record
REM https://wiki.duraspace.org/display/FEDORA34/Client+Command-line+Utilities#ClientCommand-lineUtilities-export. edit to change output location, server, port etc

set FEDORA_HOME=C:\Fedora
set CATALINA_HOME=C:\Fedora\tomcat
set JAVA_HOME=

fedora-export yodlapp1.york.ac.uk:80 %1 %2 %3 info:fedora/fedora-system:FOXML-1.1 migrate C:\vagrant_rails_dev_box\rails-dev-box\foxml_exports\theses_15_11_2018\foxml http
