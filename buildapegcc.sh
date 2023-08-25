#!/bin/sh

git clone https://github.com/ahgamut/musl-cross-make --depth=1 --branch z0.0.0
cd musl-cross-make

git clone https://github.com/jart/cosmopolitan --depth=1
cosmopolitan/bin/ape-install

sed -i -e 's/-j2/-j$proc/' -e '16 i\
proc=$(($(nproc) + 1))' .github/scripts/cosmo
bash ./.github/scripts/cosmo

sed -i -e 's#tool/scripts#bin#' -e 's/-j2/-j$proc/' -e '24 i\
proc=$(($(nproc) + 1))' -e '26 i\
$CC --update' .github/scripts/build
sed -i 's#tool/scripts#bin#' cosmo-ci.mak
bash ./.github/scripts/build