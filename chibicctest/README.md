An attempt at using chibicc instead of apegcc/cosmocc to build cosmo programs.
Currently cosmocc is still required for ld and headers.

Rough instructions on unix-likes:
```sh
git clone https://github.com/jart/cosmopolitan.git
cd cosmopolitan
make o//third_party/chibicc/chibicc

printf "#include <stdio.h>\nint main(void) { puts(\"This is a test\"); }" > chibicctest.c
o/third_party/chibicc/chibicc -fno-common -include libc/integral/normalize.inc -isystem libc/isystem/ -o chibicctest.o -c chibicctest.c
.cosmocc/3.6.2/bin/x86_64-unknown-cosmo-cc -o chibicctest chibicctest.o
.cosmocc/3.6.2/bin/apelink -l cosmo\.cosmocc\3.6.2\bin\ape-x86_64.elf -o chibicctest.com chibicctest
./chibicctest.com
```

Instructions for Windows:
```cmd
DownloadCosmo.bat
BuildChibicc.bat
BuildTest.bat
chibicctest.com
```

On Windows there is also `SetupStandalone.bat` to setup a standalone toolchain that avoids having to repeat the above.
Once built it can be used as follows:
```cmd
bin\chibicc.bat -o someprogram.o -c someprogram.c
bin\dash cosmo/.cosmocc/3.6.2/bin/x86_64-unknown-cosmo-cc -o someprogram someprogram.o
bin\apelink.com -l cosmo\.cosmocc\3.6.2\bin\ape-x86_64.elf -o someprogram.com someprogram
someprogram.com
```
