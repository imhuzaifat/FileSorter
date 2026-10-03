@echo off
rem ====================================================================
rem  FileSorter.bat  -  sort any messy folder by file type
rem
rem  EASY WAY
rem    Double-click it, or drag a folder onto it, and answer the questions.
rem
rem  COMMAND LINE (no questions asked when any flag is used)
rem    FileSorter.bat "D:\Downloads" /top /cat /dry
rem    FileSorter.bat "D:\Recovered" /sub /ext
rem    FileSorter.bat "D:\Downloads" /undo
rem    Run FileSorter.bat /? for the full list
rem ====================================================================
setlocal DisableDelayedExpansion
chcp 65001 >nul
title File Sorter

rem ---------- defaults ----------
set "ROOT="
set "MODE=sort"
set "DEPTH=2"
set "GROUP=ext"
set "DRY=0"
set "CLEAN=1"
set "SKIPEXT=crdownload part tmp"
set "FLAGS=0"
set "RC=0"

rem ---------- read arguments ----------
:parse
if "%~1"=="" goto parsed
set "ARG=%~1"
if "%ARG%"=="/?" goto help
set "ISFLAG=0"
if /i "%ARG%"=="/dry" set "DRY=1" & set "ISFLAG=1"
if /i "%ARG%"=="/top" set "DEPTH=1" & set "ISFLAG=1"
if /i "%ARG%"=="/sub" set "DEPTH=2" & set "ISFLAG=1"
if /i "%ARG%"=="/ext" set "GROUP=ext" & set "ISFLAG=1"
if /i "%ARG%"=="/cat" set "GROUP=cat" & set "ISFLAG=1"
if /i "%ARG%"=="/undo" set "MODE=undo" & set "ISFLAG=1"
if /i "%ARG%"=="/keepempty" set "CLEAN=0" & set "ISFLAG=1"
if "%ISFLAG%"=="1" set "FLAGS=1"
if "%ISFLAG%"=="0" set "ROOT=%ARG%"
shift
goto parse

:parsed
if "%FLAGS%"=="0" echo ====================================================
if "%FLAGS%"=="0" echo                  FILE SORTER
if "%FLAGS%"=="0" echo ====================================================

rem ---------- pick the folder ----------
if defined ROOT goto haveRoot
if "%FLAGS%"=="1" set "ROOT=%CD%"
if "%FLAGS%"=="1" goto haveRoot
echo.
set /p "ROOT=Folder path (paste or drag a folder here, Enter = current folder): "
if not defined ROOT set "ROOT=%CD%"

:haveRoot
set "ROOT=%ROOT:"=%"
if not exist "%ROOT%\" goto badFolder
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

rem ---------- safety guard ----------
if /i "%ROOT%"=="%SystemDrive%" goto unsafeFolder
if /i "%ROOT%"=="%SystemRoot%" goto unsafeFolder
if /i "%ROOT%"=="%ProgramFiles%" goto unsafeFolder
if /i "%ROOT%"=="%USERPROFILE%" goto unsafeFolder

echo.
echo Folder: "%ROOT%"
if "%FLAGS%"=="1" goto run

rem ---------- interactive questions ----------
echo.
echo   1 = Sort files
echo   2 = Undo the last sort in this folder
choice /c 12 /n /m "Choose 1 or 2: "
if errorlevel 2 set "MODE=undo"
if "%MODE%"=="undo" goto askDry

echo.
set "DEPTH=1"
choice /c TS /n /m "Scan [T]his folder only, or [S]ubfolders too? "
if errorlevel 2 set "DEPTH=2"

set "GROUP=ext"
choice /c EC /n /m "Group by [E]xtension (jpg, pdf) or [C]ategory (Images, Documents)? "
if errorlevel 2 set "GROUP=cat"

set "ANS="
set /p "ANS=Extensions to skip (Enter = crdownload part tmp, or type none): "
if defined ANS set "SKIPEXT=%ANS%"
if /i "%SKIPEXT%"=="none" set "SKIPEXT="

if "%DEPTH%"=="1" goto askDry
set "CLEAN=1"
choice /c YN /n /m "Delete empty folders afterwards? [Y/N] "
if errorlevel 2 set "CLEAN=0"

:askDry
set "DRY=1"
choice /c YN /n /m "Preview only (dry run) first? [Y/N] "
if errorlevel 2 set "DRY=0"
if "%DRY%"=="1" goto run
echo.
echo This will change files inside: "%ROOT%"
echo Press any key to start, or close this window to cancel.
pause >nul

rem ====================================================================
:run
if defined SKIPEXT set "SKIPEXT=%SKIPEXT:.=%"
if defined SKIPEXT set "SKIPEXT=%SKIPEXT:,= %"
if not defined SKIPEXT set "SKIPEXT=_none_"

set "MOVED=0"
set "RENAMED=0"
set "SKIPPED=0"
set "FAILED=0"
echo.
if "%DRY%"=="1" echo *** DRY RUN: nothing will be changed ***

if "%MODE%"=="undo" goto doUndo

rem ---------- sort ----------
set "LIST=%TEMP%\sortlist_%RANDOM%%RANDOM%.txt"
set "LOGTMP=%TEMP%\sortlog_%RANDOM%%RANDOM%.txt"

rem Snapshot the file list first so moved files are never picked up again.
rem Hidden and system files (desktop.ini, Thumbs.db...) are left alone.
if "%DEPTH%"=="1" dir /b /a-d-h-s "%ROOT%\" > "%LIST%" 2>nul
if "%DEPTH%"=="2" dir /s /b /a-d-h-s "%ROOT%\" > "%LIST%" 2>nul

set "TOTAL=0"
for /f %%N in ('type "%LIST%" ^| find /c /v ""') do set "TOTAL=%%N"
if "%TOTAL%"=="0" goto nothing
echo Found %TOTAL% files. Working...
echo.

if "%DEPTH%"=="1" goto topLoop
for /f "usebackq delims=" %%F in ("%LIST%") do (
    set "SRC=%%F"
    call :Process
)
goto loopDone

:topLoop
for /f "usebackq delims=" %%F in ("%LIST%") do (
    set "SRC=%ROOT%\%%F"
    call :Process
)

:loopDone
del "%LIST%" >nul 2>&1
if "%DRY%"=="0" if exist "%LOGTMP%" move /y "%LOGTMP%" "%ROOT%\_SortLog.txt" >nul 2>&1
if "%DRY%"=="0" if "%CLEAN%"=="1" if "%DEPTH%"=="2" call :Cleanup
title File Sorter

echo.
echo ====================================================
echo  Done.
echo    Moved   : %MOVED%
echo    Renamed : %RENAMED%  (duplicate names)
echo    Skipped : %SKIPPED%  (already sorted, or ignored type)
echo    Failed  : %FAILED%
echo ====================================================
if "%DRY%"=="0" if %MOVED% GTR 0 echo  Undo log saved in the folder as _SortLog.txt
if "%DRY%"=="0" if %MOVED% GTR 0 echo  To undo: run again and choose 2, or use the /undo flag.
goto end

rem ---------- undo ----------
:doUndo
set "LOGFILE=%ROOT%\_SortLog.txt"
if not exist "%LOGFILE%" goto noLog
for /f "usebackq tokens=1,2 delims=|" %%A in ("%LOGFILE%") do (
    set "CUR=%%~A"
    set "ORIG=%%~B"
    call :UndoOne
)
if "%DRY%"=="0" call :Cleanup
if "%DRY%"=="0" if "%FAILED%"=="0" if "%SKIPPED%"=="0" del "%LOGFILE%" >nul 2>&1
echo.
echo ====================================================
echo  Undo finished.
echo    Restored : %MOVED%
echo    Skipped  : %SKIPPED%  (file missing or name already taken)
echo    Failed   : %FAILED%
echo ====================================================
goto end

rem ---------- exits ----------
:nothing
del "%LIST%" >nul 2>&1
echo No files to sort in this folder.
goto end

:noLog
echo No undo log (_SortLog.txt) found in this folder.
goto end

:badFolder
echo.
echo That folder does not exist: "%ROOT%"
set "RC=1"
goto end

:unsafeFolder
echo.
echo Refusing to touch a system or profile folder: "%ROOT%"
echo Pick a more specific folder instead.
set "RC=1"
goto end

:help
echo.
echo Usage: FileSorter.bat ["folder path"] [flags]
echo.
echo   /top        only files directly inside the folder
echo   /sub        include all subfolders (default)
echo   /ext        folders by extension: jpg, pdf, docx (default)
echo   /cat        folders by category: Images, Documents, Videos...
echo   /dry        preview only, change nothing
echo   /keepempty  do not delete empty folders afterwards
echo   /undo       undo the last sort in that folder
echo.
echo With no flags, it asks you questions instead.
set "FLAGS=1"
goto end

:end
if "%FLAGS%"=="0" pause
exit /b %RC%

rem ====================================================================
rem  SUBROUTINE: handle one file (full path is in SRC)
rem  Delayed expansion stays OFF so names with ! ^ & are safe.
rem ====================================================================
:Process
if /i "%SRC%"=="%~f0" goto :eof

for %%A in ("%SRC%") do (
    set "NAME=%%~nA"
    set "DOTEXT=%%~xA"
    set "NAMEX=%%~nxA"
    set "DIR=%%~dpA"
)
if /i "%NAMEX%"=="_SortLog.txt" goto :eof

set "EXT=%DOTEXT%"
if defined EXT set "EXT=%EXT:~1%"
if not defined EXT set "EXT=_NoExtension"

set "SKIPIT=0"
for %%S in (%SKIPEXT%) do if /i "%EXT%"=="%%S" set "SKIPIT=1"
if "%SKIPIT%"=="1" goto skipCount

if "%GROUP%"=="cat" call :Categorize
if "%GROUP%"=="ext" set "CAT=%EXT%"

set "DEST=%ROOT%\%CAT%"
if /i "%DIR%"=="%DEST%\" goto skipCount

set "TARGET=%DEST%\%NAMEX%"
set "COUNT=0"

:chk
if not exist "%TARGET%" goto doMove
set /a COUNT+=1
set "TARGET=%DEST%\%NAME%_%COUNT%%DOTEXT%"
goto chk

:doMove
if %COUNT% GTR 0 set /a RENAMED+=1
if %COUNT% GTR 0 echo Duplicate renamed: "%NAMEX%" to "%NAME%_%COUNT%%DOTEXT%"
if "%DRY%"=="1" goto dryMove

if not exist "%DEST%\" mkdir "%DEST%"
move "%SRC%" "%TARGET%" >nul 2>&1
if errorlevel 1 goto moveFailed
>> "%LOGTMP%" echo "%TARGET%"^|"%SRC%"
set /a MOVED+=1
title Sorting... %MOVED% moved
goto :eof

:dryMove
echo [DRY] "%NAMEX%"  to  "%CAT%\"
set /a MOVED+=1
goto :eof

:moveFailed
set /a FAILED+=1
echo FAILED to move: "%SRC%"
goto :eof

:skipCount
set /a SKIPPED+=1
goto :eof

rem ====================================================================
rem  SUBROUTINE: map an extension to a category folder
rem  Unknown types go to Other\<ext> so nothing gets lost in one pile.
rem ====================================================================
:Categorize
set "CAT="
if not defined CAT for %%E in (jpg jpeg png gif bmp webp tif tiff svg ico heic raw cr2 nef psd) do if /i "%EXT%"=="%%E" set "CAT=Images"
if not defined CAT for %%E in (pdf doc docx txt rtf odt xls xlsx csv ppt pptx odp ods md epub) do if /i "%EXT%"=="%%E" set "CAT=Documents"
if not defined CAT for %%E in (mp4 mkv avi mov wmv flv webm m4v 3gp mpg mpeg) do if /i "%EXT%"=="%%E" set "CAT=Videos"
if not defined CAT for %%E in (mp3 wav flac aac ogg m4a wma) do if /i "%EXT%"=="%%E" set "CAT=Audio"
if not defined CAT for %%E in (zip rar 7z tar gz bz2 iso) do if /i "%EXT%"=="%%E" set "CAT=Archives"
if not defined CAT for %%E in (c cpp h hpp py java js ts html css php cs asm sh bat json xml sql) do if /i "%EXT%"=="%%E" set "CAT=Code"
if not defined CAT for %%E in (exe msi apk dmg) do if /i "%EXT%"=="%%E" set "CAT=Programs"
if not defined CAT set "CAT=Other\%EXT%"
goto :eof

rem ====================================================================
rem  SUBROUTINE: restore one file from the undo log
rem ====================================================================
:UndoOne
if not exist "%CUR%" goto undoSkip
if exist "%ORIG%" goto undoSkip
if "%DRY%"=="1" goto undoDry
for %%P in ("%ORIG%") do if not exist "%%~dpP" mkdir "%%~dpP"
move "%CUR%" "%ORIG%" >nul 2>&1
if errorlevel 1 goto undoFail
set /a MOVED+=1
goto :eof

:undoDry
echo [DRY] restore "%ORIG%"
set /a MOVED+=1
goto :eof

:undoSkip
set /a SKIPPED+=1
echo Skipped: "%ORIG%"
goto :eof

:undoFail
set /a FAILED+=1
echo FAILED to restore: "%ORIG%"
goto :eof

rem ====================================================================
rem  SUBROUTINE: delete empty folders (rd only removes EMPTY folders)
rem ====================================================================
:Cleanup
for /f "delims=" %%D in ('dir /s /b /ad "%ROOT%" 2^>nul ^| sort /r') do rd "%%D" 2>nul
goto :eof