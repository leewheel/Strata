@echo off
cd /d D:\Strata
set "FASTDL_OUT_DIR=D:\Strata-data\models\IQ1_M"
set "FASTDL_THREADS=24"
set "FASTDL_CHUNK_MB=256"
set "FASTDL_MAIN_1=https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf"
set "FASTDL_FB_1=https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf"
set "FASTDL_MAIN_2=https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
set "FASTDL_FB_2=https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
echo starting coder download to %FASTDL_OUT_DIR%
python fastdl_coder.py ^
  --out-dir "%FASTDL_OUT_DIR%" ^
  --files "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf" "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf" ^
  --main "%FASTDL_MAIN_1%" "%FASTDL_MAIN_2%" ^
  --fallback "%FASTDL_FB_1%" "%FASTDL_FB_2%" ^
  --threads %FASTDL_THREADS% ^
  --chunk-mb %FASTDL_CHUNK_MB%
echo "download exit: %errorlevel%"
pause
