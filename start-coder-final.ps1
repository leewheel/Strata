$outDir = "D:\Strata-data\models\coder-IQ1_M"
$lock = Join-Path $outDir "fastdl.lock"
if (Test-Path $lock) { Remove-Item $lock -Force -ErrorAction SilentlyContinue }
$bat = "D:\Strata\download-coder-final.bat"
Write-Host "starting bat: $bat"
$p = Start-Process -FilePath $bat -WindowStyle Hidden -PassThru
Write-Host "started pid: $($p.Id)"
Start-Sleep -Seconds 10
if ($p.HasExited) {
    Write-Host "batch exited with code: $($p.ExitCode)"
} else {
    Write-Host "batch still running"
}
