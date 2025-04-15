@echo off
setlocal enabledelayedexpansion

:: Process for proc3
echo Running for proc3...
(
    echo ftpshell proc3
    ::echo quote site attrib 3 DEOS
    ::echo b
    ::echo ftpshell proc3
    echo dir
) > temp_proc3.txt

:: Extract files from directory listing
(for /f "tokens=*" %%F in ('findstr /v "AEDB.bin emb_aedb_hr" temp_proc3.txt') do (
    echo del /CFA/%%F
)) > delete_proc3.txt

:: Run deletion commands
(
    echo ftpshell proc3
    echo quote site attrib 3 DEOS
    echo b
    echo ftpshell proc3
    type delete_proc3.txt
    echo dir
    echo b
) | cmd

:: Process for proc5
echo Running for proc5...
(
    echo ftpshell proc5
    echo quote site attrib 3 DEOS
    echo b
    echo ftpshell proc5
    echo dir
) > temp_proc5.txt

:: Extract files from directory listing
(for /f "tokens=*" %%F in ('findstr /v "AEDB.bin emb_aedb_hr" temp_proc5.txt') do (
    echo del /CFA/%%F
)) > delete_proc5.txt

:: Run deletion commands
(
    echo ftpshell proc5
    echo quote site attrib 3 DEOS
    echo b
    echo ftpshell proc5
    type delete_proc5.txt
    echo dir
    echo b
) | cmd

:: Cleanup
del temp_proc3.txt
del temp_proc5.txt
del delete_proc3.txt
del delete_proc5.txt

echo Process completed.
pause