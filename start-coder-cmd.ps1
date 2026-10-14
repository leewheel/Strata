$log = "D:\Strata\coder-download.log"
$python = "python"
$argList = @(
  "fastdl_coder.py",
  "--out-dir", "D:\Strata-data\models\IQ1_M",
  "--files", "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf", "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf",
  "--main", "https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf", "https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf",
  "--fallback", "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf", "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf",
  "--threads", "24", "--chunk-mb", "256"
)

function quote-args($aargs) {
    $result = @()
    foreach ($a in $aargs) {
        if ($a -match '\s') {
            $result += '"' + $a + '"'
        } else {
            $result += $a
        }
    }
    return $result -join ' '
}

$quoted = quote-args $argList
Write-Host "python command: python $quoted"
$cmdLine = "/c python $quoted > `"$log`" 2>&1"
Write-Host "cmd line: $cmdLine"
$p = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdLine -WindowStyle Hidden -PassThru
Write-Host "started cmd pid: $($p.Id)"
Start-Sleep -Seconds 3
if ($p.HasExited) {
    Write-Host "cmd exited with code: $($p.ExitCode)"
} else {
    Write-Host "cmd still running"
}
