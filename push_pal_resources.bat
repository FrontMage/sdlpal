@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SRC=%~1"
set "DEST=%~2"

if "%SRC%"=="" (
  echo Usage: %~nx0 ^<path-to-pal-data^> [device-dest-dir]
  echo Example: %~nx0 C:\PAL\data /storage/emulated/0/Download/pal
  exit /b 1
)

if "%DEST%"=="" set "DEST=/storage/emulated/0/Download/pal"

if not exist "%SRC%" (
  echo Source directory not found: %SRC%
  exit /b 1
)

where adb >nul 2>nul
if errorlevel 1 (
  echo adb not found in PATH.
  exit /b 1
)

adb get-state >nul 2>nul
if errorlevel 1 (
  echo No device detected by adb. Check USB debugging and run: adb devices
  exit /b 1
)

set "MISSING=0"

adb shell "mkdir -p '%DEST%'"

call :push_required abc.mkf
call :push_required ball.mkf
call :push_required data.mkf
call :push_required f.mkf
call :push_required fbp.mkf
call :push_required fire.mkf
call :push_required gop.mkf
call :push_required map.mkf
call :push_required mgo.mkf
call :push_required pat.mkf
call :push_required rgm.mkf
call :push_required rng.mkf
call :push_required sss.mkf

call :push_any message m.msg word.dat
call :push_any sound voc.mkf sounds.mkf
call :push_any music midi.mkf mus.mkf

if "%MISSING%"=="1" (
  echo Done with warnings. Some required files are missing.
  exit /b 1
)

echo All files pushed to %DEST%.
exit /b 0

:push_required
if exist "%SRC%\%~1" (
  adb push "%SRC%\%~1" "%DEST%/"
) else (
  echo Missing required file: %~1
  set "MISSING=1"
)
exit /b 0

:push_any
set "LABEL=%~1"
set "FOUND=0"
shift
:push_any_loop
if "%~1"=="" goto push_any_done
if exist "%SRC%\%~1" (
  adb push "%SRC%\%~1" "%DEST%/"
  set "FOUND=1"
)
shift
goto push_any_loop
:push_any_done
if "%FOUND%"=="0" (
  echo Missing %LABEL% file^(s^): %*
  set "MISSING=1"
)
exit /b 0
