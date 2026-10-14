@echo off
rem Detached launcher for Strata setup (AI agent use): runs unattended, logs to setup-strata.log
rem China mirrors: pip via Tsinghua (pip.ini), Hugging Face via hf-mirror.com, GitHub via ghfast.top proxy
cd /d D:\Strata
set PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
set HF_ENDPOINT=https://hf-mirror.com
set STRATA_PREBUILT_URL=https://ghfast.top/https://github.com/Niko1221/Strata/releases/latest/download/
call D:\Strata\START-HERE.bat --yes --family qwen --model IQ3_S --no-start > D:\Strata\setup-strata.log 2>&1
