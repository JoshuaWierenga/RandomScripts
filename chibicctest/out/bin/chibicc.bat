@echo off

%~dp0chibicc.com -fno-common -include %~dp0..\cosmo\include\libc\integral\normalize.inc -isystem %~dp0..\cosmo\include\ %*
