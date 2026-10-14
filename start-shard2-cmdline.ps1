$log = "D:\Strata\coder-download.log"
$python = "python"
$outDir = "D:\Strata-data\models\IQ1_M"
$files = "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
$main = "https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
$fallback = "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
$threads = 24
$chunkMb = 256

# Build command line string
$cmdLine = "/c python fastdl_coder.py --out-dir `"$outDir`" --files `"$files`" --main `"$main`" --fallback `"$fallback`" --threads $threads --chunk-mb $chunkMb > `"$log`" 2>&1"
Write-Host "cmd line: $cmdLine"
$p = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdLine -WindowStyle Hidden -PassThru
Write-Host "started cmd pid: $($p.Id)"
Start-Sleep -Seconds 5
if ($p.HasExited) {
    Write-Host "cmd exited with code: $($p.ExitCode)"
} else {
    Write-Host "cmd still running"
}
