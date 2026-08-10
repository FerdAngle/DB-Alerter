@echo off
setlocal EnableExtensions

REM - Making sure no rogue tries to open this file by itself, oh and also checking that netan passed params correctly...
if [%1]==[] (
    echo This updater must be called from MAIN_DBAlert.ahk - Click on StartAlerter.bat fool
    pause
    exit
)

REM - no point in passing directory params since the folder structure is rigid. 
set "ZIP_URL=%1"
set "WORK_DIR=%~dp0"
set "ZIP_PATH=%WORK_DIR%\DB-Alerter-v%2.zip"
set "EXTRACT_DIR=%~dp0../.." 
set "MACRO=%~dp0MAIN_DBAlert.ahk"

REM The most important line in the entire file, dont mess around with it...
cd %temp%  

REM I wanted a bit of flare with the downloading progress....
powershell -NoProfile -ExecutionPolicy Bypass ^
  "$url='%ZIP_URL%'; $out='%ZIP_PATH%';" ^
  "$req = [System.Net.HttpWebRequest]::Create($url);" ^
  "$res = $req.GetResponse();" ^
  "$total = $res.ContentLength;" ^
  "$req.Timeout = 10000;" ^
  "$stream = $res.GetResponseStream();" ^
  "$file = [System.IO.File]::OpenWrite($out);" ^
  "$buffer = New-Object byte[] 8192;" ^
  "$read = 0; $count = 0;" ^
  "while (($read = $stream.Read($buffer,0,$buffer.Length)) -gt 0) {" ^
  "  $file.Write($buffer,0,$read);" ^
  "  $count += $read;" ^
  "  $pct = [math]::Round(($count / $total) * 100);" ^
  "  Write-Progress -Activity 'Downloading update' -Status \"$pct% complete\" -PercentComplete $pct;" ^
  "}" ^
  "$file.Close(); $stream.Close();"
echo Downloaded Zip SUCESSFULLY!
timeout /t 3 >nul

if errorlevel 1 (
    echo Download failed due to timeout or connection error.
    timeout /t 3 >nul 
    exit /b 1
)

set "WAITED=0"

:find_zip
if exist "%ZIP_PATH%" goto Resume

timeout /t 1 >nul
set /a WAITED+=1

if %WAITED% GEQ 5 goto Zip_not_found
goto find_zip

:Zip_not_found 
echo Download failed. Zip not found: "%ZIP_PATH%"
timeout /t 3 >nul 
exit /b 1

:Resume
REM Extract (Windows 10+ tar)
tar -xf "%ZIP_PATH%" -C "%EXTRACT_DIR%"

REM Delete zip
del /f /q "%ZIP_PATH%"

echo UPDATING has FINISHED!
start "" "%~dp0AutoHotkeyU64.exe" "%~dp0MAIN_DBAlert.ahk"

timeout /t 2 >nul
exit /b 0
