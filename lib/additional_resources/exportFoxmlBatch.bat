@echo off
REM iterate through a text file containing pids and export the relevant foxml records as a batch

REM - How to use
REM edit to change path to input file, which is a list of pids, format york:9999, one per line
REM edit to change path to input file
REM add bin containing tee to path to allow pipe to output
SET PATH=%PATH%;<path to tee.exe>
set user=%1
set pwd=%2
for /F "tokens=*" %%A in (<fully qualified path to  text file containing pids>) do exportExam.bat %user  %pwd %%A  2>&1 1>NUL | tee -a <fully qualified name of error file to write>
