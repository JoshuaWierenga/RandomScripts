@echo off

REM Joshua's windows cosmocc wrapper script 0.1.2
REM Changes:
REM 0.1.2: Another slight instructions cleanup
REM 0.1.1: Cleaned up the instructions and fixed a bug with endlocal

goto: instend:
REM Instructions:
REM Download both buildcosmo.bat and cosmocc.bat and place in the same directory
REM Putting the cosmopolitan and cosmos directories in different locations does work but isn't recommended
REM
REM To setup cosmocc:
REM .\buildcosmo.bat o//examples/unbourne.com o//third_party/sed/sed.com o//tool/build/mv.com
REM if using cmd run set COSMO=%cd%\cosmopolitan, if using pwsh run $env:COSMO="$PWD\cosmopolitan"
REM .\cosmocc.bat --update
REM
REM To build an example program:
REM if using cmd run this whole thing including the blank line at the end
echo #include ^<stdio.h^>^

^

int main() {^

  printf("hello world\n");^

}> hello.c

REM if using pwsh then run
echo "#include <stdio.h>

int main() {
  printf(`"hello world\n`");
}" > hello.c
REM finally run: .\cosmocc.bat -o hello.com hello.c
:instend

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

"%COSMO%\o\third_party\sed\sed.com" -i ".bak" -E -e "s/^( *)((cat)|(mv))/\1cocmd.com -- \2/" -e "s/make --silent -j/make.com  --silent -j%nproc%/" -e "s/mkdir /mkdir.com /" "%COSMO%/bin/cosmocc"
"%COSMO%\o\examples\unbourne.com" "%COSMO%\bin\cosmocc" %*
move "%COSMO%\bin\cosmocc.bak" "%COSMO%\bin\cosmocc" >nul

endlocal
