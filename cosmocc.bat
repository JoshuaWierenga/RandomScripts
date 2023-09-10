@echo off

REM Joshua's windows cosmocc wrapper script 0.1.0


REM Instructions:
REM Replace SOMEPATH with wherever you put buildcosmo.bat, remove it and the \ if using the same directory
REM 
REM To setup cosmocc:
REM SOMEPATH\buildcosmo.bat o//examples/unbourne.com o//third_party/sed/sed.com o//tool/build/mv.com 
REM set COSMO=SOMEPATH\cosmopolitan
REM .\cosmocc.bat --update
REM
REM To build an example program:
REM Run whole thing including the blank line at the end
REM echo #include ^<stdio.h^>^
REM 
REM ^
REM 
REM int main() {^
REM 
REM   printf("hello world\n");^
REM 
REM }> hello.c
REM
REM .\cosmocc.bat -o hello.com hello.c

if not defined COSMO (
  exit /b 1
)
if not exist %COSMO% (
  exit /b 1
)
if not defined COSMOS (
set COSMOS=%CD%\cosmos
)

setlocal
set PATH=%COSMO%\bin;%COSMO%\build\bootstrap;%COSMO%\cosmopolitan\o\examples;%COSMO%\o\third_party\gcc\bin;%COSMO%\o\tool\build\;%PATH%

REM %NUMBER_OF_PROCESSORS% is probably fine but whatever
set /a "nproc=%NUMBER_OF_PROCESSORS%+1"
endlocal

"%COSMO%\o\third_party\sed\sed.com" -i ".bak" -E -e "s/^( *)((cat)|(mv))/\1cocmd.com -- \2/" -e "s/make --silent -j/make.com  --silent -j%nproc%/" -e "s/mkdir /mkdir.com /" "%COSMO%/bin/cosmocc"
"%COSMO%\o\examples\unbourne.com" "%COSMO%\bin\cosmocc" %*
move "%COSMO%\bin\cosmocc.bak" "%COSMO%\bin\cosmocc" >nul
