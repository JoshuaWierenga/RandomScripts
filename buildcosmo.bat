@echo off

REM Joshua's windows cosmopolitan build script 0.2.1
REM Changes:
REM 0.2.1: Use a version of ape gcc based on a much newer version of cosmo
REM 0.2.0: Worked around python test flakiness and cosmo expecting toolchain binaries with
REM        a specific prefix

if not exist cosmopolitan (
  git clone -c core.autocrlf=false https://github.com/JoshuaWierenga/cosmopolitan -b build-on-windows-3
)
cd cosmopolitan

if not exist o\third_party\gcc (
  mkdir o\third_party\gcc
  cd o\third_party\gcc
  curl -LO https://github.com/JoshuaWierenga/RandomScripts/releases/download/z0.0.0-1/gcc11.zip
  tar -xvf gcc11.zip
  del gcc11.zip
  
  REM Create versions of toolchain programs with the correct prefix and no .com suffix
  REM Cosmo's build system expects x86_64-pc-linux-gnu-{toolname} while the tools
  REM themselves just want {toolname} so this line can't just rename the files
  REM The orginal tools themselves having .com isn't actually a problem on windows as if
  REM {toolname} doesn't exist but {toolname}.com does then windows uses that. I am not
  REM entirely sure why though, perhaps a leftover from dos?
  for /R bin %%x in (*.com) do copy "%%x" "bin\x86_64-pc-linux-gnu-%%~nx" >NUL
  cd ..\..\..
)

set PATHBACKUP=%PATH%
set PATH=%PATH%;%CD%\o\third_party\gcc\bin

REM %NUMBER_OF_PROCESSORS% is probably fine but whatever
set /a "nproc=%NUMBER_OF_PROCESSORS%+1"
build\bootstrap\make.com MODE= -j%nproc%
REM Python tests are a bit flaky at higher job counts, 12 is fine on my 16 smt thread cpu
REM No clue if 5 could be too high for some systems, ideally this could be removed
build\bootstrap\make.com MODE= -j5 o//third_party/python

set PATH=%PATHBACKUP%
cd ..
