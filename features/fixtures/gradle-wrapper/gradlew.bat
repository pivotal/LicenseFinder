@echo off

where /q gradle.bat
if %ERRORLEVEL% equ 0 (
    call gradle.bat %*
) else (
    echo No Gradle installation found. Please install it from https://gradle.org/install/. >&2
    exit /b 1
)
