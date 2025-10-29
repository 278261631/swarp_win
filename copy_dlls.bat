@echo off
REM Script to copy necessary DLL files for SWarp on Windows/MSYS2

echo === SWarp DLL Copy Script ===
echo.

REM Check if build directory exists
if not exist "build\src" (
    echo Error: Build directory not found: build\src
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

REM Check if swarp.exe exists
if not exist "build\src\swarp.exe" (
    echo Error: swarp.exe not found in build\src
    echo Please compile the project first.
    pause
    exit /b 1
)

echo Found swarp.exe in build\src
echo.

REM Set MSYS2 paths
set MSYS2_BIN=C:\msys64\usr\bin
set MINGW64_BIN=C:\msys64\mingw64\bin

REM Check if MSYS2 is installed
if not exist "%MSYS2_BIN%" (
    echo Error: MSYS2 not found at %MSYS2_BIN%
    echo Please install MSYS2 or update the path in this script.
    pause
    exit /b 1
)

echo Copying required DLLs...
echo.

REM Copy msys-2.0.dll
if exist "%MSYS2_BIN%\msys-2.0.dll" (
    copy /Y "%MSYS2_BIN%\msys-2.0.dll" "build\src\" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Copied msys-2.0.dll
    ) else (
        echo [FAIL] Failed to copy msys-2.0.dll
    )
) else (
    echo [WARN] msys-2.0.dll not found
)

REM Copy msys-gcc_s-seh-1.dll
if exist "%MSYS2_BIN%\msys-gcc_s-seh-1.dll" (
    copy /Y "%MSYS2_BIN%\msys-gcc_s-seh-1.dll" "build\src\" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Copied msys-gcc_s-seh-1.dll
    ) else (
        echo [FAIL] Failed to copy msys-gcc_s-seh-1.dll
    )
) else (
    echo [WARN] msys-gcc_s-seh-1.dll not found
)

REM Copy optional pthread DLL
if exist "%MSYS2_BIN%\msys-pthread-1.dll" (
    copy /Y "%MSYS2_BIN%\msys-pthread-1.dll" "build\src\" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Copied msys-pthread-1.dll (optional)
    )
) else if exist "%MINGW64_BIN%\libwinpthread-1.dll" (
    copy /Y "%MINGW64_BIN%\libwinpthread-1.dll" "build\src\" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Copied libwinpthread-1.dll (optional)
    )
)

echo.
echo DLL files in build\src:
echo -----------------------------------
dir /B build\src\*.dll 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo No DLL files found
)

echo.
echo === Copy Complete ===
echo.
echo You can now run swarp.exe from Windows CMD:
echo   build\src\swarp.exe -v
echo.
pause

