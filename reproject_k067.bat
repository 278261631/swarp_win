@echo off
setlocal enabledelayedexpansion

REM Reproject test\K067-8-b.fit onto the WCS grid of test\K067-8.fits

set "ROOT=%~dp0"
set "SWARP="

if exist "%ROOT%build\src\swarp.exe" set "SWARP=%ROOT%build\src\swarp.exe"
if not defined SWARP if exist "%ROOT%dist\swarp.exe" set "SWARP=%ROOT%dist\swarp.exe"

if not defined SWARP (
    echo [ERROR] swarp.exe not found in build\src or dist.
    echo Please build first, or place swarp.exe in one of those locations.
    exit /b 1
)

set "SRC_NAME=K067-8-b.fit"
set "REF_NAME=K067-8.fits"
set "SRC=%ROOT%test\%SRC_NAME%"
set "REF=%ROOT%test\%REF_NAME%"
set "OUT_DIR=%ROOT%test\output\reproject"
set "EXPECTED_RESAMP_A=%OUT_DIR%\K067-8-b.fit.resamp.fits"
set "EXPECTED_RESAMP_B=%OUT_DIR%\K067-8-b.resamp.fits"
set "DIAG_LOG=%OUT_DIR%\reproject_diagnose.log"

if not exist "%SRC%" (
    echo [ERROR] Source file not found: %SRC%
    exit /b 1
)

if not exist "%REF%" (
    echo [ERROR] Reference file not found: %REF%
    exit /b 1
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
if exist "%DIAG_LOG%" del /q "%DIAG_LOG%"

pushd "%ROOT%test"
if errorlevel 1 (
    echo [ERROR] Cannot enter test directory: %ROOT%test
    exit /b 1
)

set "SRC_INPUT=%SRC_NAME%"
set "REF_INPUT=%REF_NAME%"
call :select_readable_input "%SRC_NAME%" SRC_INPUT
call :select_readable_input "%REF_NAME%" REF_INPUT

echo.
echo Using SWarp: %SWARP%
echo Source:      %SRC%
echo Reference:   %REF%
echo Source used: !SRC_INPUT!
echo Ref used:    !REF_INPUT!
echo Output dir:  %OUT_DIR%
echo.

REM Include reference image so SWarp derives the output grid from it.
REM COMBINE N keeps the run in resampling mode (no stacked coadd output needed).
"%SWARP%" "!SRC_INPUT!" "!REF_INPUT!" ^
  -c "%ROOT%test\default.swarp" ^
  -COMBINE N ^
  -RESAMPLE Y ^
  -IMAGEOUT_NAME "%OUT_DIR%\coadd.fits" ^
  -WEIGHTOUT_NAME "%OUT_DIR%\coadd.weight.fits" ^
  -RESAMPLE_DIR "%OUT_DIR%" ^
  -RESAMPLE_SUFFIX .resamp.fits ^
  -VERBOSE_TYPE NORMAL

if errorlevel 1 (
    echo.
    echo [ERROR] Reprojection failed.
    call :run_diagnostics
    popd
    exit /b 1
)

set "EXPECTED_RESAMP="
if exist "%EXPECTED_RESAMP_A%" set "EXPECTED_RESAMP=%EXPECTED_RESAMP_A%"
if not defined EXPECTED_RESAMP if exist "%EXPECTED_RESAMP_B%" set "EXPECTED_RESAMP=%EXPECTED_RESAMP_B%"

if not defined EXPECTED_RESAMP (
    echo.
    echo [ERROR] Reprojection finished but expected file was not generated.
    echo Checked:
    echo         %EXPECTED_RESAMP_A%
    echo         %EXPECTED_RESAMP_B%
    echo This usually means SWarp could not read usable data from input FITS files.
    call :run_diagnostics
    popd
    exit /b 1
)

echo.
echo [OK] Reprojection completed.
echo Check output files in: %OUT_DIR%
echo Reprojected file: !EXPECTED_RESAMP!
popd
exit /b 0

:run_diagnostics
echo.
echo [DIAG] Running extra checks...
echo [DIAG] Writing log to: %DIAG_LOG%
echo [DIAG] Running extra checks...> "%DIAG_LOG%"
echo [DIAG] SWarp executable: %SWARP%>> "%DIAG_LOG%"
echo [DIAG] Source file: %SRC%>> "%DIAG_LOG%"
echo [DIAG] Reference file: %REF%>> "%DIAG_LOG%"

for %%I in ("%SRC%") do (
    echo [DIAG] Source size: %%~zI bytes
    echo [DIAG] Source size: %%~zI bytes>> "%DIAG_LOG%"
)
for %%I in ("%REF%") do (
    echo [DIAG] Reference size: %%~zI bytes
    echo [DIAG] Reference size: %%~zI bytes>> "%DIAG_LOG%"
)

call :probe_one "src_raw" "%SRC%"
call :probe_one "src_ext0" "%SRC%[0]"
call :probe_one "src_ext1" "%SRC%[1]"
call :probe_one "ref_raw" "%REF%"
call :probe_one "ref_ext0" "%REF%[0]"
call :probe_one "ref_ext1" "%REF%[1]"

echo [DIAG] Done. Please open:
echo [DIAG]   %DIAG_LOG%
echo [DIAG] and share key warning/error lines if needed.
echo [DIAG] Done.>> "%DIAG_LOG%"
goto :eof

:probe_one
set "TAG=%~1"
set "INPUT=%~2"
echo.>> "%DIAG_LOG%"
echo ==================================================>> "%DIAG_LOG%"
echo [DIAG] Probe !TAG!: !INPUT!>> "%DIAG_LOG%"
echo [DIAG] Probe !TAG!: !INPUT!
"%SWARP%" "!INPUT!" ^
  -HEADER_ONLY Y ^
  -IMAGEOUT_NAME "%OUT_DIR%\diag_!TAG!.fits" ^
  -WEIGHTOUT_NAME "%OUT_DIR%\diag_!TAG!.weight.fits" ^
  -VERBOSE_TYPE FULL >> "%DIAG_LOG%" 2>&1
set "RC=%ERRORLEVEL%"

if !RC! GEQ 1 (
    echo [DIAG] Probe !TAG! returned ERRORLEVEL !RC!
    echo [DIAG] Probe !TAG! returned ERRORLEVEL !RC!>> "%DIAG_LOG%"
) else (
    echo [DIAG] Probe !TAG! returned ERRORLEVEL 0
    echo [DIAG] Probe !TAG! returned ERRORLEVEL 0>> "%DIAG_LOG%"
)
goto :eof

:select_readable_input
set "BASE=%~1"
set "SELECTED=%BASE%"

call :test_candidate "%BASE%"
if not errorlevel 1 goto :select_readable_done

call :test_candidate "%BASE%[0]"
if not errorlevel 1 (
    set "SELECTED=%BASE%[0]"
    goto :select_readable_done
)

call :test_candidate "%BASE%[1]"
if not errorlevel 1 set "SELECTED=%BASE%[1]"

:select_readable_done
set "%~2=%SELECTED%"
goto :eof

:test_candidate
"%SWARP%" "%~1" ^
  -HEADER_ONLY Y ^
  -IMAGEOUT_NAME "%OUT_DIR%\.__probe.fits" ^
  -WEIGHTOUT_NAME "%OUT_DIR%\.__probe.weight.fits" ^
  -VERBOSE_TYPE QUIET >nul 2>&1
exit /b %ERRORLEVEL%
