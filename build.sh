#!/bin/bash
# as = assembler
# ld = linker

clean() {
        rm -f calcasm.o write-output.o parse-input.o calcasm
}


if [[ "$1" == "clean" ]]; then
        clean
else
        clean &&
        as calcasm.s -o calcasm.o &&
        as write-output.s -o write-output.o &&
        as parse-input.s -o parse-input.o &&
        ld calcasm.o write-output.o parse-input.o -o calcasm
fi
