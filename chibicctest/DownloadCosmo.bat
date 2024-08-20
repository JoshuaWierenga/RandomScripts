@echo off

if not exist bin mkdir bin

setlocal
cd bin

set COSMOS_URL=https://cosmo.zip/pub/cosmos/v/3.7.1/bin
set COSMOSWINFDSHANGFIX_URL=https://github.com/UTAS-Programming-Club/UntitledTextAdventure/raw/1634bd6/build/bootstrap

:: if not exist dash curl -fLo dash %COSMOS_URL%/dash
if not exist dash curl -fLo dash %COSMOSWINFDSHANGFIX_URL%/sh
if not exist make curl -fLo make %COSMOSWINFDSHANGFIX_URL%/make
if not exist pwd curl -fLo pwd %COSMOS_URL%/pwd
:: if not exist sha256sum curl -fLo sha256sum %COSMOS_URL%/sha256sum
if not exist uname curl -fLo uname %COSMOS_URL%/uname.ape
:: if not exist unzip curl -fLo unzip %COSMOS_URL%/unzip
:: if not exist wget curl -fLo wget %COSMOS_URL%/wget

if not exist dash.exe copy dash dash.exe

endlocal

if not exist cosmo.tar.gz curl -fLo cosmo.tar.gz https://github.com/jart/cosmopolitan/archive/refs/tags/3.7.1.tar.gz
if not exist cosmo mkdir cosmo
if not exist cosmo\Makefile tar -xvf cosmo.tar.gz -C cosmo --strip-components=1

if not exist cosmocc.zip curl -fLo cosmocc.zip https://github.com/jart/cosmopolitan/releases/download/3.6.2/cosmocc-3.6.2.zip
if not exist cosmo\.cosmocc\3.6.2 mkdir cosmo\.cosmocc\3.6.2
if not exist cosmo\.cosmocc\3.6.2\bin\x86_64-unknown-cosmo-cc tar -xvf cosmocc.zip -C cosmo\.cosmocc\3.6.2

if not exist bin\gzip copy cosmo\.cosmocc\3.6.2\bin\gzip.ape bin\gzip
if not exist bin\mkdir copy cosmo\.cosmocc\3.6.2\bin\mkdir.ape bin\mkdir