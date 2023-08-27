#!/bin/sh

# Joshua's ape gcc build script 0.6.1
# Based on https://github.com/ahgamut/musl-cross-make/blob/cibuild/.github/workflows/release.yml
# Changes
#0.6.1: Modify cosmocc so that --update works in this environment
#0.6.0: Again use a slightly newever version of cosmo, this time from 2023/08/14
#       Needed to replace setup-cosmos script since it no longer exists
#0.5.0: Again use a slightly newever version of cosmo, this time from 2023/08/13
#       Remove chmod on cosmopolitan.a as it is no longer required
#0.4.0: Updated to a slightly newer version of cosmo with an updated cosmocc
#       Add fix for cosmocc checking for execute permission on cosmopolitan.a
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
git fetch origin d1b937bf1daa62c943e2c88434c9254328d1fac2 --depth=1
git reset --hard FETCH_HEAD
cd ..

(
export COSMO="$PWD"/cosmopolitan
export COSMOS="$PWD"/cosmos
export proc=$(($(nproc) + 1))

sed -i '7 i\
#ifndef _GETOPT_H\
#define _GETOPT_H\
#endif\
' cosmopolitan/third_party/getopt/long.h
sed -i 's/-j2/-j$proc/' .github/scripts/cosmo
cosmopolitan/bin/ape-install
bash ./.github/scripts/cosmo

sed -i -e 's#cd /opt/cosmo#cd "$COSMO"#' -e 's/if GIT/if false \&\& GIT/' cosmopolitan/bin/cosmocc
cosmopolitan/bin/cosmocc --update

sed -i -e 's#tool/scripts#bin#' -e 's/-j2/-j$proc/' .github/scripts/build
sed -i 's#tool/scripts#bin#' cosmo-ci.mak
bash ./.github/scripts/build
)
