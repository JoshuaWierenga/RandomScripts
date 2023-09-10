@echo off

REM Joshua's windows cosmopolitan build script 0.4.0
REM Changes:
REM 0.4.0: Moved zip download and extraction to a function and use in case git is unavailable
REM        Also sped up git clone, copied toolchain check from unix shell version and ensure
REM        calling shell's current directory is unchanged
REM 0.3.0: Use alternative musl toolchain prefix for cosmocc compat, transparently pass-through
REM        parameters to make and remove now unneeded second make step for python tests
REM 0.2.1: Use a version of ape gcc based on a much newer version of cosmo
REM 0.2.0: Worked around python test flakiness and cosmo expecting toolchain binaries with
REM        a specific prefix

if not exist cosmopolitan (
  where git >nul
  if %ERRORLEVEL% equ 0 (
    git clone -c core.autocrlf=false https://github.com/JoshuaWierenga/cosmopolitan --depth=1 -b build-on-windows-3
  ) else (
    call :download_zip https://github.com/JoshuaWierenga/cosmopolitan/archive/refs/heads/build-on-windows-3.zip,^
    build-on-windows-3.zip, cosmopolitan-build-on-windows-3, cosmopolitan
  )
)
setlocal
cd cosmopolitan

if not exist o\third_party\gcc\bin\x86_64-linux-musl-gcc (
  mkdir o\third_party\gcc
  cd o\third_party\gcc
  call :download_zip https://github.com/JoshuaWierenga/RandomScripts/releases/download/z0.0.0-1/gcc11.zip,^
  gcc11.zip
  
  REM Create versions of toolchain programs with the correct prefix and no .com suffix
  REM Cosmo's build system expects x86_64-linux-musl-{toolname} while the tools
  REM themselves just want {toolname} so this line can't just rename the files
  REM The orginal tools themselves having .com isn't actually a problem on windows as if
  REM {toolname} doesn't exist but {toolname}.com does then windows uses that. I am not
  REM entirely sure why though, perhaps a leftover from dos?
  for /R bin %%x in (*.com) do copy "%%x" "bin\x86_64-linux-musl-%%~nx" >NUL
  cd ..\..\..
)

set PATH=%PATH%;%CD%\o\third_party\gcc\bin

REM %NUMBER_OF_PROCESSORS% is probably fine but whatever
set /a "nproc=%NUMBER_OF_PROCESSORS%+1"
call build\bootstrap\make.com MODE= -j%nproc% %*

endlocal
exit /b %ERRORLEVEL%

:download_zip
call curl -LO %~1
call tar -xvf "%~2"
del "%~2"
if not "%~3"=="" ren "%~3" "%~4"
exit /b 0
