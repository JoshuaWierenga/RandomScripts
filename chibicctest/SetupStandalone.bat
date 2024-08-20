@echo off

mkdir out\bin\
copy bin\apelink.exe out\bin\apelink.com
copy bin\chibicc.exe out\bin\chibicc.com
copy bin\dash.exe out\bin\

xcopy cosmo\.cosmocc\3.6.2\ out\cosmo\.cosmocc\3.6.2\ /sy
xcopy cosmo\ctl\*.h out\cosmo\ctl\ /sy
xcopy cosmo\dsp\*.h out\cosmo\dsp\ /sy
xcopy cosmo\libc\*.h out\cosmo\libc\ /sy
xcopy cosmo\libc\*.inc out\cosmo\libc\ /sy
xcopy cosmo\net\*.h out\cosmo\net\ /sy
xcopy cosmo\third_party\*.h out\cosmo\third_party\ /sy
