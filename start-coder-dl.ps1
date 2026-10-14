$pyExe = "D:\Strata\.venv\Scripts\python.exe"
$log = "D:\Strata\coder-download.log"
$outDir = "D:\Strata-data\models\coder-IQ1_M"
$files = @(
  "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf",
  "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
)
$main = @(
  "https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf",
  "https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
)
$fallback = @(
  "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf",
  "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
)
$threads = 24
$chunkMb = 256

# remove stale lock
$lock = Join-Path $outDir "fastdl.lock"
if (Test-Path $lock) { Remove-Item $lock -Force -ErrorAction SilentlyContinue }

# build argument list
$argList = @()
$argList += $pyExe
$argList += "fastdl_coder.py"
$argList += "--out-dir", $outDir
$argList += "--files", $files[0], $files[1]
$argList += "--main", $main[0], $main[1]
$argList += "--fallback", $fallback[0], $fallback[1]
$argList += "--threads", $threads, "--chunk-mb", $chunkMb

Write-Host "starting download with args count: $($argList.Count)"
$p = Start-Process -FilePath $pyExe -ArgumentList $argList -RedirectStandardOutput $log -RedirectStandardError $log -UseShellExecute $false -WindowStyle Hidden -PassThru
Write-Host "started python pid: $($p.Id)"
Start-Sleep -Seconds 8
if ($p.HasExited) {
    Write-Host "python exited with code: $($p.ExitCode)"
} else {
    Write-Host "python still running"
}
