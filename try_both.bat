@echo off
setlocal enabledelayedexpansion

REM Simple launcher that tries both executables

echo ==========================================
echo sht Launcher (Try both versions)
echo ==========================================
echo.

if exist "bin\sht_debug.exe" (
    echo.
    echo Attempting debug version first...
    echo.
    echo ==========================================
    echo Running: sht_debug.exe
    echo ==========================================
    echo.
    echo Debug version has:
    echo   - Reduced logging
    echo   - Button-only mouse events
    echo   - Direct terminal mode
    echo.
    echo Press Q or ESC to quit. Mouse click to test.
    echo.
    set TERM=xterm-256color
    set NCURSES_NO_UTF8_ACS=0
    set COLORTERM=truecolor
    bin\sht_debug.exe
    set EXIT_CODE=%ERRORLEVEL%
    
    if %EXIT_CODE% equ 0 (
        echo.
        echo ==========================================
        echo SUCCESS: sht_debug.exe exited normally
        echo ==========================================
        echo.
        echo Mouse worked? If YES, use debug version going forward.
        echo If NO, try standard version below:
        echo.
    ) else (
        echo.
        echo ==========================================
        echo Failed with code: %EXIT_CODE%
        echo ==========================================
        echo.
        echo Trying standard version...
        echo.
    )
) else (
    echo ERROR: sht_debug.exe not found
    echo Run: make debug
    pause
    exit /b 1
)

if %EXIT_CODE% neq 0 (
    echo.
    echo ==========================================
    echo Trying standard version: sht.exe
    echo ==========================================
    echo.
    set TERM=xterm-256color
    set NCURSES_NO_UTF8_ACS=0
    set COLORTERM=truecolor
    bin\sht.exe
    set EXIT_CODE=%ERRORLEVEL%
)

if %EXIT_CODE% equ 0 (
    echo.
    echo ==========================================
    echo Both versions tested
    echo ==========================================
    echo.
    echo Use the version that works better for you.
) else (
    echo.
    echo ==========================================
    echo Failed with code: %EXIT_CODE%
    echo.
)

echo.
echo Press any key to close...
pause
