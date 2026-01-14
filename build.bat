@echo off
setlocal
set PATH=C:\msys64\mingw64\bin;%PATH%

echo Compiling...
gcc -Wall -Wextra -O2 -std=c11 -IC:\msys64\mingw64\include -c src\main.c -o build\main.o
if %errorlevel% neq 0 goto error

gcc -Wall -Wextra -O2 -std=c11 -IC:\msys64\mingw64\include -c src\ui.c -o build\ui.o
if %errorlevel% neq 0 goto error

echo Linking...
gcc build\main.o build\ui.o -o bin\sht.exe -LC:\msys64\mingw64\lib -lnotcurses -lnotcurses-core -lnotcurses-ffi
if %errorlevel% neq 0 goto error

echo Copying DLLs...
copy C:\msys64\mingw64\bin\libnotcurses*.dll bin\ >nul
copy C:\msys64\mingw64\bin\libgcc_s_seh-1.dll bin\ >nul
copy C:\msys64\mingw64\bin\libstdc++-6.dll bin\ >nul
copy C:\msys64\mingw64\bin\libwinpthread-1.dll bin\ >nul

echo Done!
goto end

:error
echo Build failed with error %errorlevel%
exit /b %errorlevel%

:end
endlocal
