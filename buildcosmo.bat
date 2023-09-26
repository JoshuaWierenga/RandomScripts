@echo off

REM NOTE: Until I fully test things, I recommend using 0.5.0 which uses the build-on-windows-3 branch
REM Joshua's windows cosmopolitan build script 0.5.3
REM Changes:
REM 0.5:3: Improve copy check in download function and hide excessive output when extracting comso.
REM 0.5.2: Updated apegcc version. The special handling for .com files has been removed and so
REM        the extracted binaries are renamed just like the unix shell version of the script.
REM 0.5.1: Using experimental updated cosmo version, it fails more often but most of that
REM        is from improved error detection triggering on issues that were already present.
REM 0.5.0: Updated apegcc version and prevent displaying errors from mkdir if the dir exists.
REM 0.4.0: Moved zip download and extraction to a function and use in case git is unavailable.
REM        Also sped up git clone, copied toolchain check from unix shell version and ensured
REM        calling shell's current directory is unchanged.
REM 0.3.0: Use alternative musl toolchain prefix for cosmocc compat, transparently pass-through
REM        parameters to make and remove now unneeded second make step for python tests.
REM 0.2.1: Use a version of ape gcc based on a much newer version of cosmo.
REM 0.2.0: Worked around python test flakiness and cosmo expecting toolchain binaries with
REM        a specific prefix.

if not exist cosmopolitan (
  where git >nul
  if %ERRORLEVEL% equ 0 (
    git clone -c core.autocrlf=false https://github.com/JoshuaWierenga/cosmopolitan --depth=1 -b build-on-windows-fix
  ) else (
    call :download_zip https://github.com/JoshuaWierenga/cosmopolitan/archive/refs/heads/build-on-windows-fix.zip,^
    build-on-windows-fix.zip, "2>nul", cosmopolitan-build-on-windows-fix, cosmopolitan
  )
)
setlocal
cd cosmopolitan

if not exist o\third_party\gcc\bin\x86_64-linux-musl-gcc (
  mkdir o\third_party\gcc 2>nul
  cd o\third_party\gcc
  call :download_zip https://github.com/JoshuaWierenga/RandomScripts/releases/download/z0.0.0-3/gcc11.zip,^
  gcc11.zip

  REM Create versions of toolchain programs with the correct prefix and no .com suffix
  REM Cosmo's build system expects x86_64-linux-musl-{toolname} while the tools
  REM themselves just want {toolname} so this line can't just rename the files
  for /R bin %%f in (*.com) do move "%%f" "bin\%%~nf" >nul
  for /R bin %%f in (*) do copy "%%f" "bin\x86_64-linux-musl-%%~nxf" >nul
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
REM For some reason tar -xf -v doesn't work but -v is useful for apegcc extraction and a pain for cosmo extraction
REM so for now I just put 2>nul on the end as required
call tar -xvf "%~2" %~3
del "%~2"
if not "%~4"=="" if not "%~5"=="" ren "%~4" "%~5"
exit /b 0
