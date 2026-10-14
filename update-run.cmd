@echo off
cd /d D:\Strata
rem mirror vars (reuse the same ones you used before) in case setup re-downloads anything small
set PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
set HF_ENDPOINT=https://hf-mirror.com
set STRATA_PREBUILT_URL=https://ghfast.top/https://github.com/Niko1221/Strata/releases/latest/download/
call D:\Strata\UPDATE.bat > D:\Strata\update-log.txt 2>&1
