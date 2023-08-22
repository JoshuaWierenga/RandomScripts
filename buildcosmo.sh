#!/bin/sh
# From https://stackoverflow.com/a/45181694
portable_nproc() {
  OS="$(uname -s)"
  if [ "$OS" = "Linux" ]; then
    NPROCS="$(nproc --all)"
  elif [ "$OS" = "Darwin" ] || [ "$(echo "$OS" | grep -q BSD)" = "BSD" ]; then
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
(
cd cosmopolitan || exit

if [ ! -d o/third_party/gcc ]; then
  mkdir -p o/third_party/gcc
  (
  cd o/third_party/gcc || exit
  curl -LO https://github.com/ahgamut/musl-cross-make/releases/download/z0.0.0/gcc11.zip
  tar -xvf gcc11.zip
  rm gcc11.zip
  
  # Rename toolchain programs to not have .com suffix
  # From https://unix.stackexchange.com/a/659132
  find bin -type f -name '*.com' -exec sh -c 'mv -- "$1" "${1%.*}"' sh {} \;
  )
fi

PATHBACKUP="$PATH"
PATH="$PATH:$(pwd)/o/third_party/gcc/bin"

# portable_nproc on its own is probably fine but whatever
build/bootstrap/make.com MODE= -j$(($(portable_nproc) + 1))

PATH=$PATHBACKUP
)
