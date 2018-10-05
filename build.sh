#!/bin/bash
# as = assembler
# ld = linker
if [[ "$1" == "clean" ]]; then
        rm calcasm.o write-functions.o utilities.o calcasm
else
        as calcasm.s -o calcasm.o &&
        as write-functions.s -o write-functions.o &&
        as utilities.s -o utilities.o &&
        ld calcasm.o write-functions.o utilities.o -o calcasm
fi
