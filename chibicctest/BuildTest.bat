@echo off

setlocal
set PATH=%~dp0bin;%PATH%
cd cosmo

chibicc.exe -fno-common -include libc\integral\normalize.inc -isystem libc\isystem\ -o ..\chibicctest.o -c ..\chibicctest.c
dash .cosmocc/3.6.2/bin/x86_64-unknown-cosmo-cc -o ..\chibicctest ..\chibicctest.o
apelink -l build/bootstrap/ape.elf -o ..\chibicctest.com ..\chibicctest
endlocal
