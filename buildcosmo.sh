#!/bin/sh

# Joshua's unix cosmopolitan build script 0.3
# Changes:
# 0.3: Use a version of ape gcc based on a much newer version of cosmo, script now works on
#      linux and netbsd(needs a couple of additional source changes to tests for netbsd though)
# 0.2: Worked around gnu tar not supporting zips by checking for unzip and bsdtar first
#      Also worked around cosmo expecting toolchain binaries with a specific prefix and suffix

# From https://stackoverflow.com/a/45181694
portable_nproc() {
  OS="$(uname -s)"
  if [ "$OS" = "Linux" ]; then
    NPROCS="$(nproc --all)"
  elif [ "$OS" = "Darwin" ] || [ -n "$(echo "$OS" | grep BSD)" ]; then
    NPROCS="$(sysctl -n hw.ncpu)"
  else
    NPROCS="$(getconf _NPROCESSORS_ONLN)"  # glibc/coreutils fallback
  fi
  echo "$NPROCS"
}

if [ ! -d cosmopolitan ]; then
  if command -v git > /dev/null 2>&1; then
    git clone https://github.com/JoshuaWierenga/cosmopolitan -b build-on-windows-3
  else
    curl -LO https://github.com/JoshuaWierenga/cosmopolitan/archive/refs/heads/build-on-windows-3.zip
    tar -xvf build-on-windows-3.zip
    rm build-on-windows-3.zip
    mv cosmopolitan-build-on-windows-3/ cosmopolitan
  fi
fi

cd cosmopolitan || exit

if [ ! -f o/third_party/gcc/bin/gcc ]; then
  mkdir -p o/third_party/gcc
  (
  cd o/third_party/gcc || exit
  curl -LO https://github.com/JoshuaWierenga/RandomScripts/releases/download/z0.0.0-1/gcc11.zip
  if command -v unzip > /dev/null 2>&1; then
    unzip gcc11.zip
  elif command -v bsdtar > /dev/null 2>&1; then
    bsdtar -xvf gcc11.zip
  else
    tar -xvf gcc11.zip # hope for bsdtar
  fi
  rm gcc11.zip

  # Create versions of toolchain programs with the correct prefix and no .com suffix
  # Cosmo's build system expects x86_64-pc-linux-gnu-{toolname} while the tools
  # themselves just want {toolname} so this line can't just rename the files
  # From https://unix.stackexchange.com/a/659132
  find bin -type f -exec sh -c 'mv "$1" "${1%.*}"' sh {} \;
  find bin -type f -exec sh -c 'cp "$1" bin/x86_64-pc-linux-gnu-"${1#*/}"' sh {} \;
  )
fi

PATHBACKUP="$PATH"
PATH="$PATH:$(pwd)/o/third_party/gcc/bin"

# portable_nproc on its own is probably fine but whatever
build/bootstrap/make.com MODE= -j$(($(portable_nproc) + 1))
# Python tests are a bit flaky at higher job counts, 12 is fine on my 16 smt thread cpu
# No clue if 5 could be too high for some systems, ideally this could be removed
build/bootstrap/make.com MODE= -j1 o//third_party/python

PATH=$PATHBACKUP
