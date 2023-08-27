#!/bin/sh

# Joshua's ape gcc build script 0.2
# Based on https://github.com/ahgamut/musl-cross-make/blob/cibuild/.github/workflows/release.yml
# Changes
#0.2: Reverted to an old version of cosmo that has been tested for building gcc
#     will move back to a newer version once I get that working properly

git clone https://github.com/ahgamut/musl-cross-make.git --depth=1 --branch z0.0.0
cd musl-cross-make || exit

git clone https://github.com/ahgamut/cosmopolitan.git --depth=1 --branch=gccbuild
cosmopolitan/ape/apeinstall.sh

sed -i -e 's/-j2/-j$proc/' -e '16 i\
proc=$(($(nproc) + 1))' .github/scripts/cosmo
bash ./.github/scripts/cosmo

sed -i -e 's/-j2/-j$proc/' -e '24 i\
proc=$(($(nproc) + 1))' .github/scripts/build
bash ./.github/scripts/build
