@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo sht Debug Launcher
echo ==========================================
echo.

REM Check if debug executable exists
if not exist "bin\sht_debug.exe" (
    echo ERROR: bin\sht_debug.exe not found!
    echo.
    echo To build debug version:
    echo   make debug
    echo.
    pause
    exit /b 1
)

REM Set terminal environment
set TERM=xterm-256color
set COLORTERM=truecolor

echo ==========================================
echo Debug Build Settings:
echo   - Reduced logging (NCLOGLEVEL_ERROR)
echo   - Different mouse mode (NCKEY_BUTTON_EVENT only)
echo   - Alternate screen mode off
echo ==========================================
echo.
echo Terminal environment:
echo   TERM=%TERM%
echo   COLORTERM=%COLORTERM%
echo.
echo ==========================================
echo Starting sht_debug.exe...
echo ==========================================
echo.
echo Controls:
echo   [Q] or [ESC] - Quit
echo   [Mouse] - Click to interact
echo.
echo Press Ctrl+C to interrupt if needed...
echo.
echo ---------------------------------

REM Run debug executable
.\bin\sht_debug.exe

set EXIT_CODE=%ERRORLEVEL%

echo.
echo ---------------------------------
if %EXIT_CODE% equ 0 (
    echo sht_debug.exe exited normally.
) else (
    echo sht_debug.exe exited with error code: %EXIT_CODE%
    echo.
    echo If you still see issues:
    echo   1. Try: make test
    echo   2. Check Windows Terminal settings (Ctrl+Shift+P)
    echo   3. Ensure "Use legacy console" is OFF
)

echo ---------------------------------
pause
