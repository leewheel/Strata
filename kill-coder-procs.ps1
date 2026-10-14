$procs = Get-CimInstance Win32_Process |
    Where-Object { $_.Name -eq "python.exe" -and $_.CommandLine -match "fastdl_coder" }
if ($procs) {
    foreach ($p in $procs) {
        Write-Host "killing fastdl python PID $($p.ProcessId)"
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
    }
}
$lock = Get-ChildItem -Path "D:\Strata-data\models\IQ1_M" -Filter "fastdl.lock" -ErrorAction SilentlyContinue
if ($lock) {
    Write-Host "lock file present: $($lock.FullName)"
} else {
    Write-Host "no lock file found"
}
