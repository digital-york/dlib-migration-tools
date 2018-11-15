REM iterate through a text file containing pids

@echo off
SET PATH=%PATH%;C:\HashiCorp\Vagrant\embedded\usr\bin
 set user=%1
 set pwd=%2
 echo "user in batch file"%1
 echo "password in batch file"%2
 for /F "tokens=*" %%A in (C:\Fedora\client\bin\lists\theses_15_11_2018.txt) do call exportThesis.bat %user%  %pwd% %%A  2>&1 1>NUL | tee -a C:\vagrant_rails_dev_box\rails-dev-box\foxml_exports\theses_15_11_2018\export_theses_error_log.txt

