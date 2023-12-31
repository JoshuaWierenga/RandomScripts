#!/bin/sh
# this script produces floppy images that work in qemu and vmware workstation, perhaps other vmms as well

# leave unless there are build issues
efiFullSize=1440
# set to false to produce a smaller uefi image that in qemu can only started via the efi shell, other vmms do not appear to care
qemuUefiDirectBoot=true

# ./name.com
buildLinux=false
# qemu-system-x86_64 -drive format=raw,file=$name.bios.flp -serial stdio
buildBios=false
buildUefi=false

# these only work for some build modes
strace=false
ftrace=false

vga=false

mode=fastbuild

# TODO put everything after includes and turn include checks back on
# $1: source file path
# $2: output file name
# $3: target: linux, metal
prepsource() {
    if [ "$preppedSource" = true ] ; then
        return
    fi

    cp "$1" "$2"

    if [ "$3" = metal ] ; then
        # ensure the program displays console output and doesn't try to quit on completion
        # emits are done reverse order so that they can all go on line 1, otherwise it would need to keep track
        # of which lines were skipped in order to figure out the line to put the next one on
        emitline "$1" '1s/^/wontreturn int metalend(int returnValue) {\n  printf("\\nReturn value was %d.\\n", returnValue);\n  for (;;) ;\n}\n/'

        # replace calls to exit and mbedtls_exit with a call to metalend
        # TODO replace exit calls in headers with metalend calls as well. I tried sticking a define at the top of the
        # file but that changes the original definition of exit to be called metalend in addition to the one above
        # fixing this would also remove the need for the mbedtls_exit replacement since it is just a macro for exit
        emitline "$1" 's/\([[:space:]]\{1,\}\)exit(/\1metalend(/'
        emitline "$1" 's/\([[:space:]]\{1,\}\)mbedtls_exit(/\1metalend(/'

        # based on https://unix.stackexchange.com/a/533803, replaces any returns in main with a call to metalend with the returned value.
        emitline "$1" '/main(.*{/,/^}/ s/return[[:space:]]\{1,\}\([[:alnum:]]\{1,\}\)[[:space:]]*;/metalend(\1);/'
        # in case the program doesn't have a return
        emitline "$1" '/main(.*{/,/^}/ s/^}/  metalend(0);\n}/'

        # ensure metal builds work correctly
        emitline "$1" '1s/^/__static_yoink("EfiMain");\n/' '__static_yoink("EfiMain");'
        emitline "$1" '1s/^/__static_yoink("_idt");\n/' '__static_yoink("_idt");'
    fi


    emitline "$1" '1s/^/#include "libc\/stdio\/stdio.h"\n/' #'#include "libc[\/]stdio[\/]stdio.h"'

    # TODO figure out why calling ShowCrashReports sometimes causes crashes
    #emitline "$1" '/main(.*{/ a\  ShowCrashReports();' 'ShowCrashReports();'
    
    if [ "$vga" = true ] ; then
        emitline "$1" '1s/^/__static_yoink("vga_console");\n/' '__static_yoink("vga_console");'
    fi

    if [ "$strace" = true ] ; then
        emitline "$1" '1s/^/#include "libc\/runtime\/runtime.h"\n/' #'#include "libc[\/]runtime[\/]runtime.h"'
        emitline "$1" '/main(.*{/ a\  strace_enabled(+1);' 'strace_enabled(+1);'
    fi

    if [ "$ftrace" = true ] ; then
        emitline "$1" '1s/^/#include "libc\/runtime\/runtime.h"\n/' #'#include "libc[\/]runtime[\/]runtime.h"'
        emitline "$1" '1s/^/__static_yoink("__zipos_get");\n/' '__static_yoink("__zipos_get");'
        emitline "$1" '/main(.*{/ a\  ftrace_install();' 'ftrace_install();'
        emitline "$1" '/main(.*{/ a\  ftrace_enabled(+1);' 'ftrace_enabled(+1);'
    fi

    preppedSource=true
}

# $1: path to a cosmo c source file (including name)
# $2: name of the same cosmo c source file
restoresource() {
    [ ! -f "$2" ] || mv "$2" "$1"
}

# $1: path of the file to emit to
# $2: emitting sed pattern
# $3: optional sed pattern to check for first, only emits if it find nothing
emitline() {
    if [ -n "$3" ] ; then
        optionaltextline=$(sed -n '/'"$3"'/{=;q;}' "$1")
        if [ -n "$optionaltextline" ] ; then
            return
        fi
    fi

    sed "$2" "$1" > temp.c && mv temp.c "$1"
}

# can be run in three ways
# 1. 3 arguments:
# $1: path to the cosmo git repo
# $2: path to a cosmo binary relative to the cosmo git repo
# $3: target to build for: linux, bios or uefi
# 2. no arguments, builds hardcoded program for bios and uefi
# 3. 1 argument = clean, cleans up and quits

# TODO restore support for writing images to usbs
# TODO find a way to output one image that works on bios and uefi
if [ "$#" -eq 3 ] ; then
    sourceFileName=${2##*/} # dir/.../dir/file.ext -> file.ext
    baseSourceFileName=${sourceFileName%.c} # file.c -> file

    makePath=o/$mode/${2%.c}.com # path to output file relative to the cosmo git repo

    if [ "$3" = linux ] ; then
        buildLinux=true
        destinationLinux=$baseSourceFileName.com
    elif [ "$3" = bios ] ; then
        buildBios=true
        destinationBios=$baseSourceFileName.bios.flp
    elif [ "$3" = uefi ] ; then
        buildUefi=true
        destinationUefi=$baseSourceFileName.uefi.flp
    fi
elif [ "$#" -eq 0 ] ; then
    set -- /opt/cosmo/
    makePath=o/$mode/examples/vga2.com # path to output file relative to the cosmo git repo

    buildBios=true
    buildUefi=true

    destinationLinux=cosmo.com
    destinationBios=cosmo.bios.flp
    destinationUefi=cosmo.uefi.flp
elif [ "$1" = clean ] ; then
    rm -rf ./*.com ./*.flp
    exit 0
else
    exit 1
fi

binaryPath=$1//$makePath # path to output file relative to the current directory
rm "$binaryPath"

if [ "$buildLinux" = true ] ; then
    prepsource "$1/$2" "$sourceFileName" linux
    (cd "$1" && make m="$mode" "$makePath" -j"$(($(nproc) + 1))")
    restoresource "$1/$2" "$sourceFileName"
    cp "$binaryPath" "$destinationLinux"
fi

if [ "$buildBios" = true ] ; then
    prepsource "$1/$2" "$sourceFileName" metal
    (cd "$1" && make m="$mode" "$makePath" -j"$(($(nproc) + 1))")
    restoresource "$1/$2" "$sourceFileName"
    cp "$binaryPath" "$destinationBios"
fi

# Based on https://gitlab.com/-/snippets/2548098
if [ "$buildUefi" = true ] ; then
    prepsource "$1/$2" "$sourceFileName" metal
    (cd "$1" && make m="$mode" "$makePath" -j"$(($(nproc) + 1))")
    restoresource "$makePath" "$sourceFileName"
    if [ "$qemuUefiDirectBoot" = true ] ; then
        dd status=none if=/dev/zero of="$destinationUefi" bs=1024 count="$efiFullSize"
    else
        dd status=none if=/dev/zero of="$destinationUefi" bs=1024 count=1
    fi
    mkdosfs -F 12 -g 1/8 -M 0xfe -r 16 -s 2 --mbr=y "$destinationUefi" "$efiFullSize"
    # fix the partition type byte (this may not be needed, but is good to do)
    printf '\xef' | dd status=none of="$destinationUefi" bs=1 seek=450 conv=notrunc
    mmd -i "$destinationUefi" ::efi
    mmd -i "$destinationUefi" ::efi/boot
    mcopy -i "$destinationUefi" "$binaryPath" ::efi/boot/bootx64.efi
    sync
fi
