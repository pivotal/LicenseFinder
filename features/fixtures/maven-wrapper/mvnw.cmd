@echo off
where /q mvn.cmd
if %ERRORLEVEL% equ 0 (
    mvn.cmd %*
) else (
    mvn.bat %*
)
