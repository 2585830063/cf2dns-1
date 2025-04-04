@echo off
title CF2DNS 自动化脚本
color 0A
setlocal enabledelayedexpansion

:: 配置区域 ---------------------------------------------------
set "VENV_PYTHON=C:\Users\Admin\anaconda3\envs\cf\python.exe"
set "SCRIPT=cf2dns_global.py"
set "LOGS_DIR=logs"
:: -----------------------------------------------------------

:: 强制设置工作目录为脚本位置
cd /d "%~dp0"

:: 创建日志目录（带错误处理）
mkdir "%LOGS_DIR%" 2>nul || (
    echo [错误] 无法创建日志目录 "%LOGS_DIR%"
    pause
    exit /b 1
)

:: 生成带时间戳的日志文件名
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "datetime=%%a"
set "datetime=!datetime:~0,8!_!datetime:~8,6!"
set "LOG_FILE=%LOGS_DIR%\cf2dns_!datetime!.log"

:: 运行脚本并捕获输出（PowerShell 兼容模式）
echo [信息] 启动时间: %date% %time% > "%LOG_FILE%"
echo [信息] 虚拟环境路径: "%VENV_PYTHON%" | tee -a "%LOG_FILE%"

:: 使用 PowerShell 的 Tee-Object 替代 tee
PowerShell -Command "& '%VENV_PYTHON%' '%SCRIPT%' 2>&1 | Tee-Object -FilePath '%LOG_FILE%' -Append"

:: 错误处理
if %errorlevel% neq 0 (
    echo [错误] 运行失败! 错误代码: %errorlevel% | tee -a "%LOG_FILE%"
    echo 详细错误请查看日志: %LOG_FILE%
    pause
    exit /b 1
)

:: 成功提示
echo [成功] 脚本执行完成 | tee -a "%LOG_FILE%"
pause