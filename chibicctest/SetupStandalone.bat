@echo off

mkdir out\bin\
copy bin\apelink.exe out\bin\apelink.com
copy bin\chibicc.exe out\bin\chibicc.com
copy bin\dash.exe out\bin\

xcopy cosmo\.cosmocc\3.6.2\ out\cosmo\.cosmocc\3.6.2\ /y
mkdir out\cosmo\.cosmocc\3.6.2\bin\
copy cosmo\.cosmocc\3.6.2\bin\apelink out\cosmo\.cosmocc\3.6.2\bin\
copy cosmo\.cosmocc\3.6.2\bin\ape-x86_64.elf out\cosmo\.cosmocc\3.6.2\bin\
copy cosmo\.cosmocc\3.6.2\bin\fixupobj out\cosmo\.cosmocc\3.6.2\bin\
xcopy cosmo\.cosmocc\3.6.2\bin\unknown-unknown-cosmo-* out\cosmo\.cosmocc\3.6.2\bin\ /y
xcopy cosmo\.cosmocc\3.6.2\bin\x86_64-unknown-cosmo-* out\cosmo\.cosmocc\3.6.2\bin\ /y
xcopy cosmo\.cosmocc\3.6.2\bin\x86_64-linux-cosmo-* out\cosmo\.cosmocc\3.6.2\bin\ /y
xcopy cosmo\.cosmocc\3.6.2\include\ out\cosmo\.cosmocc\3.6.2\include\ /sy
mkdir out\cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\
copy cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\as out\cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\
copy cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\ld out\cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\
copy cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\ld.bfd out\cosmo\.cosmocc\3.6.2\libexec\gcc\x86_64-linux-cosmo\14.1.0\
xcopy cosmo\.cosmocc\3.6.2\x86_64-linux-cosmo\ out\cosmo\.cosmocc\3.6.2\x86_64-linux-cosmo\ /sy
xcopy cosmo\ctl\*.h out\cosmo\ctl\ /sy
xcopy cosmo\dsp\*.h out\cosmo\dsp\ /sy
xcopy cosmo\libc\*.h out\cosmo\libc\ /sy
xcopy cosmo\libc\*.inc out\cosmo\libc\ /sy
xcopy cosmo\net\*.h out\cosmo\net\ /sy
xcopy cosmo\third_party\*.h out\cosmo\third_party\ /sy
