#!/bin/sh

# Joshua's ape gcc build script 0.3.0
# Based on https://github.com/ahgamut/musl-cross-make/blob/cibuild/.github/workflows/release.yml
# Changes
#0.3.0: Use a newer version of cosmo from 2023/08/12 instead of one from 2023/07/25
#       Cleanup cosmo download code slightly but not using a subshell
#0.2.1: Using same cosmo commit but now from the main repo, manually add getopt change
#0.2.0: Reverted to an old version of cosmo that has been tested for building gcc
#       will move back to a newer version once I get that working properly

git clone https://github.com/ahgamut/musl-cross-make.git --depth=1 --branch z0.0.0
cd musl-cross-make || exit

mkdir cosmopolitan
cd cosmopolitan || exit
git init
git remote add origin https://github.com/jart/cosmopolitan.git
git fetch origin 8fc778162ecd227c66cac0333cdb66bdcec9662c --depth=1
git reset --hard FETCH_HEAD
cd ..

cosmopolitan/ape/apeinstall.sh
sed -i '7 i\
#ifndef _GETOPT_H\
#define _GETOPT_H\
#endif\
' cosmopolitan/third_party/getopt/long.h

sed -i -e 's/-j2/-j$proc/' -e '16 i\
proc=$(($(nproc) + 1))' .github/scripts/cosmo
bash ./.github/scripts/cosmo

sed -i -e 's/-j2/-j$proc/' -e '24 i\
proc=$(($(nproc) + 1))' .github/scripts/build
bash ./.github/scripts/build
