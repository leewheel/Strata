@echo off
cd /d D:\Strata
python -u fastdl_coder.py ^
  --out-dir "D:\Strata-data\models\IQ1_M" ^
  --files "Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf" ^
  --main "https://www.modelscope.cn/models/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/master/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf" ^
  --fallback "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf" ^
  --threads 24 --chunk-mb 256
