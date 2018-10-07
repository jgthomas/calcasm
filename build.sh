#!/bin/bash
# as = assembler
# ld = linker
if [[ "$1" == "clean" ]]; then
        rm calcasm.o write-output.o parse-input.o calcasm
else
        as calcasm.s -o calcasm.o &&
        as write-output.s -o write-output.o &&
        as parse-input.s -o parse-input.o &&
        ld calcasm.o write-output.o parse-input.o -o calcasm
fi
