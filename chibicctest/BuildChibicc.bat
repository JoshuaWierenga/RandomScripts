@echo off

setlocal
:: set PATH=%~dp0cosmo\build\bootstrap;%~dp0bin;%PATH%
set PATH=%~dp0bin;%PATH%
cd cosmo

:: dash build/download-cosmocc.sh $(COSMOCC) 3.6.2 268aa82d9bfd774f76951b250f87b8edcefd5c754b8b409e1639641e8bd8d5b
if not exist o\third_party\chibicc\chibicc dash ../batchtodash.sh make SHELL=dash -j17 o//third_party/chibicc/chibicc
if not exist o\tool\build\apelink dash ../batchtodash.sh make SHELL=dash -j17 o//tool/build/apelink

if not exist ..\bin\chibicc.exe copy o\third_party\chibicc\chibicc ..\bin\chibicc.exe
if not exist ..\bin\apelink.exe copy o\tool\build\apelink ..\bin\apelink.exe
endlocal
