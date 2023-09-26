#!/bin/sh

# NOTE: Until I fully test things, I recommend using 0.3.0 which uses the build-on-windows-3 branch
# Joshua's unix cosmopolitan build script 0.4.2
# Changes:
# 0.4.2: Moved zip download and extraction to a function to ensure unzip/bsdtar/tar check is done.
#        Updated apegcc version.
# 0.4.1: Fix gcc check.
# 0.4.0: Port some features from the batch version including quicker cosmo download via depth,
#        better gcc setup and remove now unneeded second make step for python tests.
#        Fixed failure to create the gcc directory not stopping the script.
#        Use an updated gcc build and an experimental updated cosmo version, the build fails more
#        but most of that is from improved error detection triggering on already present issues.
# 0.3.0: Use a version of ape gcc based on a much newer version of cosmo, the script now works on
#        linux and netbsd(needs a couple of additional source changes to tests for netbsd though).
# 0.2.0: Worked around gnu tar not supporting zips by checking for unzip and bsdtar first.
#        Also worked around cosmo expecting toolchain binaries with a specific prefix and suffix.

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

download_zip() {
  curl -LO $1
  if command -v unzip > /dev/null 2>&1; then
    unzip "$2"
  elif command -v bsdtar > /dev/null 2>&1; then
    bsdtar -xvf "$2"
  else
    tar -xvf "$2" # hope for bsdtar
  fi
  rm "$2"
  if [ -n "$3" ] && [ -n "$4" ]; then
    mv "$3" "$4"
  fi
}

if [ ! -d cosmopolitan ]; then
  if command -v git > /dev/null 2>&1; then
    git clone https://github.com/JoshuaWierenga/cosmopolitan --depth=1 -b build-on-windows-fix
  else
    download_zip https://github.com/JoshuaWierenga/cosmopolitan/archive/refs/heads/build-on-windows-fix.zip \
    build-on-windows-fix.zip cosmopolitan-build-on-windows-fix/ cosmopolitan/
  fi
fi
cd cosmopolitan || exit

if [ ! -f o/third_party/gcc/bin/x86_64-linux-musl-gcc ]; then
  mkdir -p o/third_party/gcc
  cd o/third_party/gcc || exit
  download_zip https://github.com/JoshuaWierenga/RandomScripts/releases/download/z0.0.0-3/gcc11.zip \
  gcc11.zip

  # Create versions of toolchain programs with the correct prefix and no .com suffix
  # Cosmo's build system expects x86_64-linux-musl-{toolname} while the tools
  # themselves just want {toolname} so this line can't just rename the files
  # From https://unix.stackexchange.com/a/659132
  find bin -type f -exec sh -c 'mv "$1" "${1%.*}"' sh {} \;
  find bin -type f -exec sh -c 'cp "$1" bin/x86_64-linux-musl-"${1#*/}"' sh {} \;
  cd ../../../
fi

(
PATH="$PATH:$(pwd)/o/third_party/gcc/bin"

# portable_nproc on its own is probably fine but whatever
build/bootstrap/make.com MODE= -j$(($(portable_nproc) + 1))
)
