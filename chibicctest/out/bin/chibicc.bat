@echo off

:: cd %~dp0..\cosmo
%~dp0chibicc.com -fno-common -include %~dp0..\cosmo\libc\integral\normalize.inc -isystem %~dp0..\cosmo\ -isystem %~dp0..\cosmo\.cosmocc\3.6.2\include\ %*
