@echo off
REM SPYK3-PHISH v11.0.0 Installation Script for Windows
REM Author: Ian Carter Kulani

setlocal enabledelayedexpansion

title SPYK3-PHISH Installer
color 0A

echo ================================================================
echo      🌿 SPYK3-PHISH v11.0.0 - Windows Installation
echo ================================================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] This installer requires administrator privileges
    echo Please run as Administrator for full functionality
    echo.
)

REM Check Python installation
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python not found!
    echo Please install Python 3.7+ from https://python.org
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VER=%%i
echo [OK] Python %PYTHON_VER% found

REM Check pip
echo [INFO] Checking pip...
pip --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] pip not found!
    pause
    exit /b 1
)
echo [OK] pip found

REM Create virtual environment
echo [INFO] Creating virtual environment...
python -m venv venv
if %errorLevel% neq 0 (
    echo [ERROR] Failed to create virtual environment
    pause
    exit /b 1
)
echo [OK] Virtual environment created

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

REM Install requirements
echo [INFO] Installing Python packages...
pip install cryptography requests psutil colorama paramiko python-nmap python-whois scapy qrcode[pil] pyshorteners discord.py telethon slack-sdk selenium webdriver-manager aiohttp pyOpenSSL dnspython netifaces

if %errorLevel% neq 0 (
    echo [ERROR] Failed to install packages
    pause
    exit /b 1
)
echo [OK] Packages installed

REM Create directories
echo [INFO] Creating directories...
mkdir .spyk3_phish 2>nul
mkdir .spyk3_phish\payloads 2>nul
mkdir .spyk3_phish\workspaces 2>nul
mkdir .spyk3_phish\scans 2>nul
mkdir .spyk3_phish\nikto_results 2>nul
mkdir .spyk3_phish\whatsapp_session 2>nul
mkdir .spyk3_phish\phishing_pages 2>nul
mkdir reports 2>nul
mkdir .spyk3_phish\traffic_logs 2>nul
mkdir .spyk3_phish\phishing_templates 2>nul
mkdir .spyk3_phish\captured_credentials 2>nul
mkdir .spyk3_phish\ssh_keys 2>nul
mkdir .spyk3_phish\ssh_logs 2>nul
mkdir .spyk3_phish\time_history 2>nul
mkdir .spyk3_phish\wordlists 2>nul
echo [OK] Directories created

REM Create run script
echo [INFO] Creating run script...
(
echo @echo off
echo call venv\Scripts\activate.bat
echo python spyk3_phish.py %%*
) > run.bat
echo [OK] Run script created (run.bat)

REM Create desktop shortcut
echo [INFO] Creating desktop shortcut...
set SCRIPT_PATH=%~dp0run.bat
set SHORTCUT_PATH=%USERPROFILE%\Desktop\SPYK3-PHISH.lnk

powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%SHORTCUT_PATH%'); $SC.TargetPath = '%SCRIPT_PATH%'; $SC.WorkingDirectory = '%~dp0'; $SC.Save()"
if %errorLevel% equ 0 (
    echo [OK] Desktop shortcut created
) else (
    echo [WARNING] Could not create desktop shortcut
)

REM Check for nmap
echo [INFO] Checking optional tools...
where nmap >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] nmap found
) else (
    echo [WARNING] nmap not found - Install from https://nmap.org
)

where nikto >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] nikto found
) else (
    echo [WARNING] nikto not found - Install from https://github.com/sullo/nikto
)

echo.
echo ================================================================
echo           ✅ SPYK3-PHISH Installation Complete!
echo ================================================================
echo.
echo 🚀 To run SPYK3-PHISH:
echo    Double-click run.bat or run: python spyk3_phish.py
echo.
echo 📖 Documentation:
echo    Type 'help' for command list
echo    Type 'crunch_charset' for CRUNCH character sets
echo    Type 'traffic_help' for traffic generation
echo.
echo 💡 Tip: Run as Administrator for full functionality
echo.

pause