@echo off

if not exist cosmopolitan (git clone -c core.autocrlf=false https://github.com/JoshuaWierenga/cosmopolitan -b build-on-windows-3)
cd cosmopolitan

if not exist o\third_party\gcc (
  mkdir o\third_party\gcc
  cd o\third_party\gcc
  curl -LO https://github.com/ahgamut/musl-cross-make/releases/download/z0.0.0/gcc11.zip
  REM copy ..\..\..\..\gcc11.zip .
  tar -xvf gcc11.zip
  del gcc11.zip
  cd ..\..\..
)

set PATHBACKUP=%PATH%
set PATH=%PATH%;%CD%\o\third_party\gcc\bin

REM %NUMBER_OF_PROCESSORS% is probably fine but whatever
set /a "nproc=%NUMBER_OF_PROCESSORS%+1"
build\bootstrap\make.com MODE= -j%nproc%

set PATH=%PATHBACKUP%
cd ..