@echo off

setlocal
set PATH=%~dp0bin;%PATH%
cd cosmo

if not exist o\third_party\chibicc\chibicc dash ../batchtodash.sh make SHELL=dash -j17 o//third_party/chibicc/chibicc
if not exist ..\bin\chibicc.exe copy o\third_party\chibicc\chibicc ..\bin\chibicc.exe
endlocal
