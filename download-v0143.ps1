$outDir = "D:\Strata\outside"
$zipPath = Join-Path $outDir "Strata-main.zip"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$url = "https://github.com/Niko1221/Strata/archive/refs/heads/main.zip"
Write-Host "downloading from $url"
Write-Host "target: $zipPath"
$start = Get-Date
Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
$end = Get-Date
$l = Get-Item $zipPath
Write-Host "done. bytes: $($l.Length), seconds: $([math]::Round(($end-$start).TotalSeconds,1))"
Write-Host "hash (sha256 first 32 chars):"
$hasher = [System.Security.Cryptography.SHA256]::Create()
$hash = $hasher.ComputeHash([System.IO.File]::ReadAllBytes($zipPath))
$hashStr = [System.Convert]::ToHexString($hash)
Write-Host $hashStr.Substring(0, [Math]::Min(32, $hashStr.Length))
