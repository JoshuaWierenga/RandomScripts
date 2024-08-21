@echo off

mkdir out\bin\
copy bin\apelink.exe out\bin\apelink.com
copy bin\chibicc.exe out\bin\chibicc.com
copy bin\dash.exe out\bin\

xcopy cosmo\.cosmocc\3.6.2\ out\cosmo\ /y
mkdir out\cosmo\bin\
copy cosmo\.cosmocc\3.6.2\bin\ape-x86_64.elf out\cosmo\bin\
copy cosmo\.cosmocc\3.6.2\bin\fixupobj out\cosmo\bin\
copy cosmo\.cosmocc\3.6.2\bin\x86_64-linux-cosmo-gcc out\cosmo\bin\
copy cosmo\.cosmocc\3.6.2\bin\x86_64-unknown-cosmo-cc out\cosmo\bin\
xcopy cosmo\.cosmocc\3.6.2\include\ out\cosmo\include\ /sy
xcopy cosmo\dsp\*.h out\cosmo\include\dsp\ /sy
mkdir out\cosmo\libexec\gcc\x86_64-linux-cosmo\14.1.0\
copy cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\ld out\cosmo\libexec\gcc\x86_64-linux-cosmo\14.1.0\
xcopy cosmo\.cosmocc\3.6.2\x86_64-linux-cosmo\ out\cosmo\x86_64-linux-cosmo\ /sy
