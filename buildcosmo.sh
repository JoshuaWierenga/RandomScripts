#!/bin/sh

if [ ! -f cosmopolitan ]; then
  git clone https://github.com/JoshuaWierenga/cosmopolitan -b build-on-windows-3
fi
(
cd cosmopolitan || exit

if [ ! -f o/third_party/gcc ]; then
  mkdir -p o/third_party/gcc
  (
  cd o/third_party/gcc || exit
  curl -LO https://github.com/ahgamut/musl-cross-make/releases/download/z0.0.0/gcc11.zip
  tar -xvf gcc11.zip
  rm gcc11.zip
  )
fi

PATHBACKUP="$PATH"
PATH="$PATH:$(PWD)/o/third_party/gcc/bin"

# nproc on its own is probably fine but whatever
build/bootstrap/make.com MODE= -j$(($(nproc) + 1))

PATH=$PATHBACKUP
)